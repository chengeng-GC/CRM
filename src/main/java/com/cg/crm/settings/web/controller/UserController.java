package com.cg.crm.settings.web.controller;

import com.cg.crm.settings.domain.User;
import com.cg.crm.settings.service.UserService;
import com.cg.crm.settings.service.impl.UserServiceImpl;
import com.cg.crm.utils.*;
import com.cg.crm.vo.PaginationVO;
import com.cg.crm.workbench.domain.Activity;
import com.cg.crm.workbench.service.ActivityService;
import com.cg.crm.workbench.service.impl.ActivityServiceImpl;

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
        }else if ("/settings/user/pageList.do".equals(path)){
            pageList(req,resp);
        }else if ("/settings/user/save.do".equals(path)){
            save(req,resp);
        }else if ("/settings/user/xxx.do".equals(path)){
            //xxx(req,resp);
        }
    }

    private void save(HttpServletRequest req, HttpServletResponse resp) {
        //System.out.println("到达save页controller层");
        UserService userService= (UserService) ServiceFactory.getService(new UserServiceImpl());
        String id= UUIDUtil.getUUID();
        String loginAct=req.getParameter("loginAct");
        String name=req.getParameter("name");
        String loginPwd=req.getParameter("loginPwd");
        loginPwd= MD5Util.getMD5(loginPwd);
        String email=req.getParameter("email");
        String expireTime=req.getParameter("expireTime");
        String lockState=req.getParameter("lockState");
        String deptno=req.getParameter("deptno");
        String allowIps=req.getParameter("allowIps");
        String createTime= DateTimeUtil.getSysTime();
        String createBy=((User)req.getSession().getAttribute("user")).getName();
        User u=new User();
        u.setId(id);
        u.setLoginAct(loginAct);
        u.setCreateBy(createBy);
        u.setCreateTime(createTime);
        u.setAllowIps(allowIps);
        u.setDeptno(deptno);
        u.setLockState(lockState);
        u.setExpireTime(expireTime);
        u.setEmail(email);
        u.setLoginPwd(loginPwd);
        u.setName(name);
        boolean flag=userService.save(u);
        PrintJson.printJsonFlag(resp,flag);


    }

    private void pageList(HttpServletRequest req, HttpServletResponse resp) {
       // System.out.println("到达user页controller层");

        UserService userService= (UserService) ServiceFactory.getService(new UserServiceImpl());
        int pageNo= Integer.valueOf(req.getParameter("pageNo"));
        int pageSize= Integer.valueOf(req.getParameter("pageSize"));
        String name =req.getParameter("name");
        String deptno=req.getParameter("deptno");
        String lockState=req.getParameter("lockState");
        String expireTimeF=req.getParameter("expireTimeF");
        String expireTimeB=req.getParameter("expireTimeB");
        //计算出略过的记录数
        int skipCount=(pageNo-1)*pageSize;
        if (!lockState.equals("")&&lockState!=null){
        if (lockState.equals("锁定")){
            lockState="0";
        }else {
            lockState="1";
        }
        }

        System.out.println(name);

        Map<String,Object> map=new HashMap<String, Object>();
        map.put("name",name);
        map.put("deptno",deptno);
        map.put("lockState",lockState);
        map.put("expireTimeF",expireTimeF);
        map.put("expireTimeB",expireTimeB);
        map.put("skipCount",skipCount);
        map.put("pageSize",pageSize);
        PaginationVO<User> vo= userService.pageList(map);
        PrintJson.printJsonObj(resp,vo);

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
