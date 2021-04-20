package com.cg.crm.workbench.web.controller;

import com.cg.crm.settings.domain.User;
import com.cg.crm.settings.service.UserService;
import com.cg.crm.settings.service.impl.UserServiceImpl;
import com.cg.crm.utils.DateTimeUtil;
import com.cg.crm.utils.PrintJson;
import com.cg.crm.utils.ServiceFactory;
import com.cg.crm.utils.UUIDUtil;
import com.cg.crm.vo.PaginationVO;
import com.cg.crm.workbench.domain.Contacts;
import com.cg.crm.workbench.domain.Customer;
import com.cg.crm.workbench.service.ContactsService;
import com.cg.crm.workbench.service.CustomerService;
import com.cg.crm.workbench.service.impl.ContactsServiceImpl;
import com.cg.crm.workbench.service.impl.CustomerServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class ContactsController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        //获取请求地址
        String path = req.getServletPath();
        //判断执行方法
        if ("/workbench/contacts/pageList.do".equals(path)) {
            pageList(req, resp);
        } else if ("/workbench/contacts/getUserList.do".equals(path)) {
            getUserList(req, resp);
        } else if ("/workbench/contacts/getCustomerName.do".equals(path)) {
            getCustomerName(req, resp);
        } else if ("/workbench/contacts/save.do".equals(path)) {
            save(req, resp);
        } else if ("/workbench/contacts/delete.do".equals(path)) {
            delete(req, resp);
        } else if ("/workbench/contacts/getUserListAndContacts.do".equals(path)) {
            getUserListAndContacts(req, resp);
        } else if ("/workbench/contacts/update.do".equals(path)) {
            update(req, resp);
        }  else if ("/workbench/contacts/xxx.do".equals(path)) {
            //xxx(req, resp);
        } else if ("/workbench/contacts/xxx.do".equals(path)) {
            //xxx(req, resp);
        }else if ("/workbench/contacts/xxx.do".equals(path)) {
            //xxx(req, resp);
        } else if ("/workbench/contacts/xxx.do".equals(path)) {
            //xxx(req, resp);
        }else if ("/workbench/contacts/xxx.do".equals(path)) {
            //xxx(req, resp);
        } else if ("/workbench/contacts/xxx.do".equals(path)) {
            //xxx(req, resp);
        }
    }

    private void update(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入update Controller层");
        String id = req.getParameter("id");
        String owner = req.getParameter("owner");
        String source = req.getParameter("source");
        String customerName = req.getParameter("customerName");
        String fullname = req.getParameter("fullname");
        String appellation = req.getParameter("appellation");
        String email = req.getParameter("email");
        String mphone = req.getParameter("mphone");
        String job = req.getParameter("job");
        String birth = req.getParameter("birth");
        String editBy = ((User) req.getSession().getAttribute("user")).getName();
        String editTime = DateTimeUtil.getSysTime();
        String description = req.getParameter("description");
        String contactSummary = req.getParameter("contactSummary");
        String nextContactTime = req.getParameter("nextContactTime");
        String address = req.getParameter("address");
        Contacts con = new Contacts();
        con.setId(id);
        con.setOwner(owner);
        con.setSource(source);
        con.setFullname(fullname);
        con.setAppellation(appellation);
        con.setEmail(email);
        con.setMphone(mphone);
        con.setJob(job);
        con.setBirth(birth);
        con.setEditBy(editBy);
        con.setEditTime(editTime);
        con.setDescription(description);
        con.setContactSummary(contactSummary);
        con.setNextContactTime(nextContactTime);
        con.setAddress(address);
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        boolean flag = contactsService.update(con, customerName);
        PrintJson.printJsonFlag(resp, flag);


    }

    private void getUserListAndContacts(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入getUserListAndContacts Controller层");
        String id = req.getParameter("id");
        UserService userService = (UserService) ServiceFactory.getService(new UserServiceImpl());
        List<User> uList = userService.getUserList();
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        Contacts c = contactsService.getUserListAndContacts(id);
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("uList", uList);
        map.put("c", c);
        PrintJson.printJsonObj(resp, map);
    }

    private void delete(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入delete Controller层");
        String[] ids = req.getParameterValues("id");
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        boolean flag = contactsService.delete(ids);
        PrintJson.printJsonFlag(resp, flag);

    }

    private void save(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入save Controller层");
        String id = UUIDUtil.getUUID();
        String owner = req.getParameter("owner");
        String source = req.getParameter("source");
        String customerName = req.getParameter("customerName");
        String fullname = req.getParameter("fullname");
        String appellation = req.getParameter("appellation");
        String email = req.getParameter("email");
        String mphone = req.getParameter("mphone");
        String job = req.getParameter("job");
        String birth = req.getParameter("birth");
        String createBy = ((User) req.getSession().getAttribute("user")).getName();
        String createTime = DateTimeUtil.getSysTime();
        String description = req.getParameter("description");
        String contactSummary = req.getParameter("contactSummary");
        String nextContactTime = req.getParameter("nextContactTime");
        String address = req.getParameter("address");
        Contacts con = new Contacts();
        con.setId(id);
        con.setOwner(owner);
        con.setSource(source);
        con.setFullname(fullname);
        con.setAppellation(appellation);
        con.setEmail(email);
        con.setMphone(mphone);
        con.setJob(job);
        con.setBirth(birth);
        con.setCreateBy(createBy);
        con.setCreateTime(createTime);
        con.setDescription(description);
        con.setContactSummary(contactSummary);
        con.setNextContactTime(nextContactTime);
        con.setAddress(address);
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        boolean flag = contactsService.save(con, customerName);
        PrintJson.printJsonFlag(resp, flag);


    }

    private void getCustomerName(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入getCustomerName Controller层");
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        String name = req.getParameter("name");
        List<String> nList = customerService.getCustomerName(name);
        PrintJson.printJsonObj(resp, nList);
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
        String fullname = req.getParameter("fullname");
        String owner = req.getParameter("owner");
        String customerName = req.getParameter("customerName");
        String source = req.getParameter("source");
        String birth = req.getParameter("birth");
        int skipPage = (pageNo - 1) * pageSize;
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("pageSize", pageSize);
        map.put("fullname", fullname);
        map.put("owner", owner);
        map.put("customerName", customerName);
        map.put("source", source);
        map.put("birth", birth);
        map.put("skipPage", skipPage);

        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        PaginationVO<Contacts> vo = contactsService.pageList(map);

        PrintJson.printJsonObj(resp, vo);
    }
}
