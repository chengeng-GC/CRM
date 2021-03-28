package com.cg.crm.web.filter;


import javax.servlet.*;
import java.io.IOException;

public class EncodingFilter implements Filter {
    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain) throws IOException, ServletException {
        //过滤post请求会因为字符编码问题乱码
        req.setCharacterEncoding("utf-8");
        //过滤响应流响应中文乱码问题
        resp.setContentType("text/html;charset=utf-8");
        //将请求放行
        chain.doFilter(req,resp);
    }
}
