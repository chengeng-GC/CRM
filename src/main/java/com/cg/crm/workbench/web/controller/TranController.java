package com.cg.crm.workbench.web.controller;

import com.cg.crm.settings.domain.User;
import com.cg.crm.settings.service.UserService;
import com.cg.crm.settings.service.impl.UserServiceImpl;
import com.cg.crm.utils.PrintJson;
import com.cg.crm.utils.ServiceFactory;
import com.cg.crm.workbench.dao.CustomerDao;
import com.cg.crm.workbench.service.CustomerService;
import com.cg.crm.workbench.service.TranService;
import com.cg.crm.workbench.service.impl.CustomerServiceImpl;
import com.cg.crm.workbench.service.impl.TranServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class TranController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        //获取请求地址
        String path = req.getServletPath();
        //判断执行方法
        if ("/workbench/transaction/save.do".equals(path)) {
            save(req, resp);
        } else if ("/workbench/transaction/getCustomerName.do".equals(path)) {
            getCustomerName(req, resp);
        } else if ("/workbench/transaction/xxx.do".equals(path)) {
            //xxx(req,resp);
        } else if ("/workbench/transaction/xxx.do".equals(path)) {
            //xxx(req,resp);
        } else if ("/workbench/transaction/xxx.do".equals(path)) {
            //xxx(req,resp);
        } else if ("/workbench/transaction/xxx.do".equals(path)) {
            //xxx(req,resp);
        } else if ("/workbench/transaction/xxx.do".equals(path)) {
            //xxx(req,resp);
        } else if ("/workbench/transaction/xxx.do".equals(path)) {
            //xxx(req,resp);
        } else if ("/workbench/transaction/xxx.do".equals(path)) {
            //xxx(req,resp);
        } else if ("/workbench/transaction/xxx.do".equals(path)) {
            //xxx(req,resp);
        }
    }

    private void getCustomerName(HttpServletRequest req, HttpServletResponse resp) {
        String name = req.getParameter("name");
        CustomerService customerService= (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        List<String> sList= customerService.getCustomerName(name);
        PrintJson.printJsonObj(resp,sList);
    }

    private void save(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        UserService userService = (UserService) ServiceFactory.getService(new UserServiceImpl());
        List<User> uList = userService.getUserList();

        req.setAttribute("uList", uList);
        req.getRequestDispatcher("/workbench/transaction/save.jsp").forward(req, resp);

    }


}
