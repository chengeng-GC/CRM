package com.cg.crm.workbench.web.controller;

import com.cg.crm.settings.domain.User;
import com.cg.crm.settings.service.UserService;
import com.cg.crm.settings.service.impl.UserServiceImpl;
import com.cg.crm.utils.DateTimeUtil;
import com.cg.crm.utils.PrintJson;
import com.cg.crm.utils.ServiceFactory;
import com.cg.crm.utils.UUIDUtil;
import com.cg.crm.workbench.dao.CustomerDao;
import com.cg.crm.workbench.domain.Tran;
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
        } else if ("/workbench/transaction/add.do".equals(path)) {
            add(req,resp);
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

    private void add(HttpServletRequest req, HttpServletResponse resp) throws IOException {
       String id= UUIDUtil.getUUID();
       String owner= req.getParameter("owner");
       String money= req.getParameter("money");
       String name= req.getParameter("name");
       String expectedDate= req.getParameter("expectedDate");
       String customerName= req.getParameter("customerName");
       String stage= req.getParameter("stage");
       String type= req.getParameter("type");
       String source= req.getParameter("source");
       String activityId= req.getParameter("activityId");
       String contactsId= req.getParameter("contactsId");
       String createBy= ((User)req.getSession().getAttribute("user")).getName();
       String createTime= DateTimeUtil.getSysTime();
       String description= req.getParameter("description");
       String contactSummary= req.getParameter("contactSummary");
       String nextContactTime= req.getParameter("nextContactTime");
       Tran t=new Tran();
       t.setId(id);
       t.setOwner(owner);
       t.setMoney(money);
       t.setName(name);
       t.setExpectedDate(expectedDate);
       t.setStage(stage);
       t.setType(type);
       t.setSource(source);
       t.setActivityId(activityId);
       t.setContactsId(contactsId);
       t.setCreateTime(createTime);
       t.setCreateBy(createBy);
       t.setDescription(description);
       t.setContactSummary(contactSummary);
       t.setNextContactTime(nextContactTime);

       TranService  tranService= (TranService) ServiceFactory.getService(new TranServiceImpl());
       boolean flag=tranService.add(t,customerName);
       if (flag){
           resp.sendRedirect(req.getContextPath()+"/workbench/transaction/index.jsp");
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
