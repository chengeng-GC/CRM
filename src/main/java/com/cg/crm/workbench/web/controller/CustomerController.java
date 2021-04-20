package com.cg.crm.workbench.web.controller;

import com.cg.crm.settings.domain.User;
import com.cg.crm.settings.service.UserService;
import com.cg.crm.settings.service.impl.UserServiceImpl;
import com.cg.crm.utils.DateTimeUtil;
import com.cg.crm.utils.PrintJson;
import com.cg.crm.utils.ServiceFactory;
import com.cg.crm.utils.UUIDUtil;
import com.cg.crm.vo.PaginationVO;
import com.cg.crm.workbench.domain.Customer;
import com.cg.crm.workbench.domain.CustomerRemark;
import com.cg.crm.workbench.service.CustomerService;
import com.cg.crm.workbench.service.impl.ClueServiceImpl;
import com.cg.crm.workbench.service.impl.CustomerServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CustomerController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        //获取请求地址
        String path = req.getServletPath();
        //判断执行方法
        if ("/workbench/customer/pageList.do".equals(path)) {
            pageList(req, resp);
        } else if ("/workbench/customer/getUserList.do".equals(path)) {
            getUserList(req, resp);
        } else if ("/workbench/customer/save.do".equals(path)) {
            save(req, resp);
        } else if ("/workbench/customer/getUserListAndCustomer.do".equals(path)) {
            getUserListAndCustomer(req, resp);
        } else if ("/workbench/customer/update.do".equals(path)) {
            update(req, resp);
        } else if ("/workbench/customer/delete.do".equals(path)) {
            delete(req, resp);
        } else if ("/workbench/customer/detail.do".equals(path)) {
            detail(req, resp);
        } else if ("/workbench/customer/showRemarkListByCid.do".equals(path)) {
            showRemarkListByCid(req, resp);
        } else if ("/workbench/customer/saveRemark.do".equals(path)) {
            saveRemark(req, resp);
        } else if ("/workbench/customer/deleteRemark.do".equals(path)) {
            deleteRemark(req, resp);
        } else if ("/workbench/customer/updateRemark.do".equals(path)) {
            updateRemark(req, resp);
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

    private void updateRemark(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入updateRemark Controller层");
        String id = req.getParameter("id");
        String noteContent = req.getParameter("noteContent");
        String editBy = ((User) req.getSession().getAttribute("user")).getName();
        String editTime =DateTimeUtil.getSysTime();
        String editFlag ="1";
        CustomerRemark cr=new CustomerRemark();
        cr.setId(id);
        cr.setNoteContent(noteContent);
        cr.setEditBy(editBy);
        cr.setEditTime(editTime);
        cr.setEditFlag(editFlag);
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        boolean flag=customerService.updateRemark(cr);
        PrintJson.printJsonFlag(resp,flag);

    }

    private void deleteRemark(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入deleteRemark Controller层");
        String id = req.getParameter("id");
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        boolean flag = customerService.deleteRemark(id);
        PrintJson.printJsonFlag(resp, flag);
    }

    private void saveRemark(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入saveRemark Controller层");
        String id = UUIDUtil.getUUID();
        String noteContent = req.getParameter("noteContent");
        String createBy = ((User) req.getSession().getAttribute("user")).getName();
        String createTime = DateTimeUtil.getSysTime();
        String editFlag = "0";
        String customerId = req.getParameter("customerId");
        CustomerRemark cr = new CustomerRemark();
        cr.setId(id);
        cr.setNoteContent(noteContent);
        cr.setCreateBy(createBy);
        cr.setCreateTime(createTime);
        cr.setEditFlag(editFlag);
        cr.setCustomerId(customerId);
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        boolean flag = customerService.saveRemark(cr);
        PrintJson.printJsonFlag(resp, flag);

    }

    private void showRemarkListByCid(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入showRemarkListByCid Controller层");
        String customerId = req.getParameter("customerId");
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        List<CustomerRemark> crList = customerService.showRemarkListByCid(customerId);
        PrintJson.printJsonObj(resp, crList);

    }

    private void detail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        System.out.println("进入detail Controller层");
        String id = req.getParameter("id");
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        Customer c = customerService.detail(id);
        req.setAttribute("c", c);
        req.getRequestDispatcher("/workbench/customer/detail.jsp").forward(req, resp);

    }

    private void delete(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入delete Controller层");
        String[] ids = req.getParameterValues("id");
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        boolean flag = customerService.delete(ids);
        PrintJson.printJsonFlag(resp, flag);
    }

    private void update(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入update Controller层");
        String id = req.getParameter("id");
        String owner = req.getParameter("owner");
        String name = req.getParameter("name");
        String website = req.getParameter("website");
        String phone = req.getParameter("phone");
        String editBy = ((User) req.getSession().getAttribute("user")).getName();
        String editTime = DateTimeUtil.getSysTime();
        String contactSummary = req.getParameter("contactSummary");
        String nextContactTime = req.getParameter("nextContactTime");
        String description = req.getParameter("description");
        String address = req.getParameter("address");
        Customer c = new Customer();
        c.setId(id);
        c.setOwner(owner);
        c.setName(name);
        c.setWebsite(website);
        c.setPhone(phone);
        c.setEditBy(editBy);
        c.setEditTime(editTime);
        c.setContactSummary(contactSummary);
        c.setNextContactTime(nextContactTime);
        c.setDescription(description);
        c.setAddress(address);
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        boolean flag = customerService.update(c);
        PrintJson.printJsonFlag(resp, flag);

    }

    private void getUserListAndCustomer(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入getUserListAndCustomer Controller层");
        String id = req.getParameter("id");
        UserService userService = (UserService) ServiceFactory.getService(new UserServiceImpl());
        List<User> uList = userService.getUserList();
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        Customer c = customerService.getUserListAndCustomer(id);
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("uList", uList);
        map.put("c", c);
        PrintJson.printJsonObj(resp, map);
    }

    private void save(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入save Controller层");
        String id = UUIDUtil.getUUID();
        String owner = req.getParameter("owner");
        String name = req.getParameter("name");
        String website = req.getParameter("website");
        String phone = req.getParameter("phone");
        String createBy = ((User) req.getSession().getAttribute("user")).getName();
        String createTime = DateTimeUtil.getSysTime();
        String contactSummary = req.getParameter("contactSummary");
        String nextContactTime = req.getParameter("nextContactTime");
        String description = req.getParameter("description");
        String address = req.getParameter("address");
        Customer c = new Customer();
        c.setId(id);
        c.setOwner(owner);
        c.setName(name);
        c.setWebsite(website);
        c.setPhone(phone);
        c.setCreateBy(createBy);
        c.setCreateTime(createTime);
        c.setContactSummary(contactSummary);
        c.setNextContactTime(nextContactTime);
        c.setDescription(description);
        c.setAddress(address);
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        boolean flag = customerService.save(c);
        PrintJson.printJsonFlag(resp, flag);


    }

    private void getUserList(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入getUserList Controller层");
        UserService userService = (UserService) ServiceFactory.getService(new UserServiceImpl());
        List<User> uList = userService.getUserList();
        PrintJson.printJsonObj(resp, uList);
    }

    private void pageList(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入pageList Controller层");
        int pageNo = Integer.valueOf(req.getParameter("pageNo"));
        int pageSize = Integer.valueOf(req.getParameter("pageSize"));
        String name = req.getParameter("name");
        String owner = req.getParameter("owner");
        String phone = req.getParameter("phone");
        String website = req.getParameter("website");
        int skipPage = (pageNo - 1) * pageSize;
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("pageSize", pageSize);
        map.put("name", name);
        map.put("owner", owner);
        map.put("phone", phone);
        map.put("website", website);
        map.put("skipPage", skipPage);

        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        PaginationVO<Customer> vo = customerService.pageList(map);
        PrintJson.printJsonObj(resp, vo);
    }
}

