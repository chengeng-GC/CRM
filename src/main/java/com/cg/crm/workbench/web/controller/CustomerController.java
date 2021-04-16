package com.cg.crm.workbench.web.controller;

import com.cg.crm.utils.PrintJson;
import com.cg.crm.utils.ServiceFactory;
import com.cg.crm.vo.PaginationVO;
import com.cg.crm.workbench.domain.Customer;
import com.cg.crm.workbench.service.CustomerService;
import com.cg.crm.workbench.service.impl.ClueServiceImpl;
import com.cg.crm.workbench.service.impl.CustomerServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class CustomerController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        //获取请求地址
        String path = req.getServletPath();
        //判断执行方法
        if ("/workbench/customer/pageList.do".equals(path)) {
            pageList(req, resp);
        } else if ("/workbench/customer/xxx.do".equals(path)) {
            //xxx(req, resp);
        } else if ("/workbench/customer/xxx.do".equals(path)) {
            //xxx(req, resp);
        } else if ("/workbench/customer/xxx.do".equals(path)) {
            //xxx(req, resp);
        } else if ("/workbench/customer/xxx.do".equals(path)) {
            //xxx(req, resp);
        } else if ("/workbench/customer/xxx.do".equals(path)) {
            //xxx(req, resp);
        } else if ("/workbench/customer/xxx.do".equals(path)) {
            //xxx(req, resp);
        } else if ("/workbench/customer/xxx.do".equals(path)) {
            //xxx(req, resp);
        } else if ("/workbench/customer/xxx.do".equals(path)) {
            //xxx(req, resp);
        } else if ("/workbench/customer/xxx.do".equals(path)) {
            //xxx(req, resp);
        } else if ("/workbench/customer/xxx.do".equals(path)) {
            //xxx(req, resp);
        }
    }

    private void pageList(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入pageList Controller层");
        int pageNo = Integer.valueOf(req.getParameter("pageNo"));
        int pageSize = Integer.valueOf(req.getParameter("pageSize"));
        String name = req.getParameter("name");
        String owner = req.getParameter("owner");
        String phone = req.getParameter("phone");
        String website = req.getParameter("website");
        int skipPage=(pageNo-1)*pageSize;
        Map<String,Object> map=new HashMap<String, Object>();
        map.put("pageSize",pageSize);
        map.put("name",name);
        map.put("owner",owner);
        map.put("phone",phone);
        map.put("website",website);
        map.put("skipPage",skipPage);

        CustomerService customerService= (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        PaginationVO<Customer> vo=customerService.pageList(map);
        PrintJson.printJsonObj(resp,vo);
    }
}

