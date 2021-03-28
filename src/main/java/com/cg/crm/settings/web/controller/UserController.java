package com.cg.crm.settings.web.controller;

import com.cg.crm.settings.domain.User;
import com.cg.crm.settings.service.UserService;
import com.cg.crm.settings.service.impl.UserServiceImpl;
import com.cg.crm.utils.MD5Util;
import com.cg.crm.utils.PrintJson;
import com.cg.crm.utils.ServiceFactory;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

//            作为contoller，需要为ajax请求提供多项信息
//            可以有两种手段来处理：
//                  （1）将多项信息打包成为map，将map解析为json串
//                  （2）创建一个Vo类
//                       private boolean success;
//                       private String msg;
//            如果对于展现的信息将来还会大量的使用，我们创建一个vo类，使用方便
//            如果对于展现的信息只有在这个需求中能够使用，我们使用map就可以了


public class UserController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        //获取请求地址
        String path=req.getServletPath();
        //判断执行方法
        if ("/settings/user/login.do".equals(path)){
            login(req,resp);
        }else if ("/settings/user/xxx.do".equals(path)){
            //xxx(req,resp);
        }
    }

    private void login(HttpServletRequest req, HttpServletResponse resp) {

        //接收账号密码
        String loginAct=req.getParameter("loginAct");
        String loginPwd=req.getParameter("loginPwd");
        //将密码的明文形式转换为MD5的密文形式
        loginPwd= MD5Util.getMD5(loginPwd);
        //接收浏览器的ip地址
        String ip=req.getRemoteAddr();

        //创建service对象
        //未来业务层开发，统一使用代理类形态的接口对象
        UserService userService= (UserService) ServiceFactory.getService(new UserServiceImpl());

        try {
            //service层工作并返回数据
            //login(String,String,String);
            User user=userService.login(loginAct,loginPwd,ip);
            //将user对象保存到Session域对象中
            req.getSession().setAttribute("user",user);
            //程序执行到此处，说明业务层没有任何异常，登录成功
            //工具类PrintJson使用
            PrintJson.printJsonFlag(resp,true);
        }catch (Exception e){
            //一旦程序执行了catch块信息，说明service层为controller层抛出了异常，登录失败
            String msg=e.getMessage();
            Map<String,Object> map=new HashMap<String, Object>();
            map.put("success",false);
            map.put("msg",msg);
            PrintJson.printJsonObj(resp,map);
        }


    }


}
