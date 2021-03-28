package com.cg.crm.web.filter;

import com.cg.crm.settings.domain.User;

import javax.servlet.*;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class LoginFilter implements Filter {
    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain) throws IOException, ServletException {
        //要拿到session里的user
        HttpServletRequest request= (HttpServletRequest) req;
        HttpServletResponse response= (HttpServletResponse) resp;
        //不应该被拦截的资源，放行
        String path=request.getServletPath();
        if ("/login.jsp".equals(path)||"/settings/user/login.do".equals(path)){
            chain.doFilter(req,resp);
        }else {
            //其他资源
            HttpSession session = request.getSession();
            User user = (User) session.getAttribute("user");
            //如果user不为null，说明登录过
            if (user != null) {
                chain.doFilter(req, resp);
            } else {
                //没有登陆过,重定向到登录页
                response.sendRedirect(request.getContextPath() + "/login.jsp");
            }
        }
    }
}
