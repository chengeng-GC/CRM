package com.cg.crm.workbench.web.controller;

import com.cg.crm.settings.domain.DicValue;
import com.cg.crm.settings.domain.User;
import com.cg.crm.settings.service.UserService;
import com.cg.crm.settings.service.impl.UserServiceImpl;
import com.cg.crm.utils.DateTimeUtil;
import com.cg.crm.utils.PrintJson;
import com.cg.crm.utils.ServiceFactory;
import com.cg.crm.utils.UUIDUtil;
import com.cg.crm.vo.PaginationVO;
import com.cg.crm.workbench.dao.CustomerDao;
import com.cg.crm.workbench.domain.*;
import com.cg.crm.workbench.service.ActivityService;
import com.cg.crm.workbench.service.ContactsService;
import com.cg.crm.workbench.service.CustomerService;
import com.cg.crm.workbench.service.TranService;
import com.cg.crm.workbench.service.impl.ActivityServiceImpl;
import com.cg.crm.workbench.service.impl.ContactsServiceImpl;
import com.cg.crm.workbench.service.impl.CustomerServiceImpl;
import com.cg.crm.workbench.service.impl.TranServiceImpl;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
        } else if ("/workbench/transaction/detail.do".equals(path)) {
            detail(req,resp);
        } else if ("/workbench/transaction/showHistoryListByTranId.do".equals(path)) {
            showHistoryListByTranId(req,resp);
        } else if ("/workbench/transaction/changeState.do".equals(path)) {
            changeState(req,resp);
        } else if ("/workbench/transaction/getCharts.do".equals(path)) {
            getCharts(req,resp);
        } else if ("/workbench/transaction/pageList.do".equals(path)) {
            pageList(req,resp);
        } else if ("/workbench/transaction/delete.do".equals(path)) {
            delete(req,resp);
        } else if ("/workbench/transaction/edit.do".equals(path)) {
            edit(req,resp);
        } else if ("/workbench/transaction/showAcitivityListByName.do".equals(path)) {
            showAcitivityListByName(req,resp);
        } else if ("/workbench/transaction/getContactsListByName.do".equals(path)) {
            getContactsListByName(req,resp);
        } else if ("/workbench/transaction/update.do".equals(path)) {
            update(req,resp);
        } else if ("/workbench/transaction/showRemarkListByTid.do".equals(path)) {
            showRemarkListByTid(req,resp);
        } else if ("/workbench/transaction/deleteRemark.do".equals(path)) {
            deleteRemark(req,resp);
        } else if ("/workbench/transaction/updateRemark.do".equals(path)) {
            updateRemark(req,resp);
        } else if ("/workbench/transaction/saveRemark.do".equals(path)) {
            saveRemark(req,resp);
        } else if ("/workbench/transaction/xxx.do".equals(path)) {
            //xxx(req,resp);
        } else if ("/workbench/transaction/xxx.do".equals(path)) {
            //xxx(req,resp);
        } else if ("/workbench/transaction/xxx.do".equals(path)) {
            //xxx(req,resp);
        }
    }

    private void saveRemark(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入saveRemark Controller层");
        String id = UUIDUtil.getUUID();
        String noteContent = req.getParameter("noteContent");
        String createBy = ((User) req.getSession().getAttribute("user")).getName();
        String createTime = DateTimeUtil.getSysTime();
        String editFlag = "0";
        String tranId = req.getParameter("tranId");
        TranRemark tr=new TranRemark();
        tr.setId(id);
        tr.setNoteContent(noteContent);
        tr.setCreateBy(createBy);
        tr.setCreateTime(createTime);
        tr.setEditFlag(editFlag);
        tr.setTranId(tranId);
        TranService  tranService= (TranService) ServiceFactory.getService(new TranServiceImpl());
        boolean flag = tranService.saveRemark(tr);
        PrintJson.printJsonFlag(resp, flag);
    }

    private void updateRemark(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入updateRemark Controller层");
        String id = req.getParameter("id");
        String noteContent = req.getParameter("noteContent");
        String editBy = ((User) req.getSession().getAttribute("user")).getName();
        String editTime =DateTimeUtil.getSysTime();
        String editFlag ="1";
        TranRemark tr=new TranRemark();
        tr.setId(id);
        tr.setNoteContent(noteContent);
        tr.setEditBy(editBy);
        tr.setEditTime(editTime);
        tr.setEditFlag(editFlag);
        TranService  tranService= (TranService) ServiceFactory.getService(new TranServiceImpl());
        boolean flag=tranService.updateRemark(tr);
        PrintJson.printJsonFlag(resp,flag);
    }

    private void deleteRemark(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入deleteRemark Controller层");
        String id=req.getParameter("id");
        TranService  tranService= (TranService) ServiceFactory.getService(new TranServiceImpl());
        boolean flag=tranService.deleteRemark(id);
        PrintJson.printJsonFlag(resp,flag);
    }

    private void showRemarkListByTid(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入showRemarkListByTid Controller层");
        String tranId=req.getParameter("tranId");
        TranService  tranService= (TranService) ServiceFactory.getService(new TranServiceImpl());
        List<TranRemark> trList=tranService.showRemarkListByTid(tranId);
        PrintJson.printJsonObj(resp,trList);

    }

    private void update(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        System.out.println("进入update Controller层");
        String id= req.getParameter("id");
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
        String editBy= ((User)req.getSession().getAttribute("user")).getName();
        String editTime= DateTimeUtil.getSysTime();
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
        t.setEditBy(editBy);
        t.setEditTime(editTime);
        t.setDescription(description);
        t.setContactSummary(contactSummary);
        t.setNextContactTime(nextContactTime);

        TranService  tranService= (TranService) ServiceFactory.getService(new TranServiceImpl());
        boolean flag=tranService.update(t,customerName);
        if (flag){
            resp.sendRedirect(req.getContextPath()+"/workbench/transaction/index.jsp");
        }
    }

    private void getContactsListByName(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入getContactsListByName Controller层");
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        String name = req.getParameter("name");
        List<Contacts> cList = contactsService.getContactsListByName(name);
        PrintJson.printJsonObj(resp, cList);

    }

    private void showAcitivityListByName(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入showAcitivityListByName Controller层");
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        String name = req.getParameter("name");
        List<Activity> aList = activityService.getAcitivityListByName(name);
        PrintJson.printJsonObj(resp, aList);
    }

    private void edit(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        System.out.println("进入edite Controller层");
        String id=req.getParameter("id");
        UserService userService = (UserService) ServiceFactory.getService(new UserServiceImpl());
        List<User> uList = userService.getUserList();
        TranService  tranService= (TranService) ServiceFactory.getService(new TranServiceImpl());
        Map<String,Object> map=tranService.edit(id);
        Tran t= (Tran) map.get("t");
        String contactsName= (String) map.get("contactsName");
        String activityName= (String) map.get("activityName");

        Map<String,String> pMap= (Map<String, String>) req.getServletContext().getAttribute("pMap");
        String possibility=pMap.get(t.getStage());
        t.setPossibility(possibility);

        req.setAttribute("uList", uList);
        req.setAttribute("t",t);
        req.setAttribute("contactsName",contactsName);
        req.setAttribute("activityName",activityName);
        req.getRequestDispatcher("/workbench/transaction/edit.jsp").forward(req, resp);

    }

    private void delete(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入delete Controller层");
        String[] ids = req.getParameterValues("id");
        TranService  tranService= (TranService) ServiceFactory.getService(new TranServiceImpl());
        boolean flag = tranService.delete(ids);
        PrintJson.printJsonFlag(resp, flag);
    }

    private void pageList(HttpServletRequest req, HttpServletResponse resp) {
        System.out.println("进入pageList Controller层");
        int pageNo = Integer.valueOf(req.getParameter("pageNo"));
        int pageSize = Integer.valueOf(req.getParameter("pageSize"));
        String name = req.getParameter("name");
        String owner = req.getParameter("owner");
        String customerName = req.getParameter("customerName");
        String source = req.getParameter("source");
        String stage = req.getParameter("stage");
        String type = req.getParameter("type");
        String contactsName = req.getParameter("contactsName");
        int skipPage = (pageNo - 1) * pageSize;
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("pageSize", pageSize);
        map.put("name", name);
        map.put("owner", owner);
        map.put("customerName", customerName);
        map.put("source", source);
        map.put("stage", stage);
        map.put("type", type);
        map.put("contactsName", contactsName);
        map.put("skipPage", skipPage);
        TranService  tranService= (TranService) ServiceFactory.getService(new TranServiceImpl());
        PaginationVO<Tran> vo = tranService.pageList(map);
        PrintJson.printJsonObj(resp, vo);
    }

    private void getCharts(HttpServletRequest req, HttpServletResponse resp) {
        TranService  tranService= (TranService) ServiceFactory.getService(new TranServiceImpl());
        Map<String,Object> map=tranService.getCharts();
        PrintJson.printJsonObj(resp,map);
    }

    private void changeState(HttpServletRequest req, HttpServletResponse resp) {
        TranService  tranService= (TranService) ServiceFactory.getService(new TranServiceImpl());
        String id=req.getParameter("id");
        String stage=req.getParameter("stage");
        String money=req.getParameter("money");
        String expectedDate=req.getParameter("expectedDate");
        String editBy= ((User)req.getSession().getAttribute("user")).getName();
        String editTime= DateTimeUtil.getSysTime();

        Tran t=new Tran();
        t.setId(id);
        t.setStage(stage);
        t.setMoney(money);
        t.setExpectedDate(expectedDate);
        t.setEditBy(editBy);
        t.setEditTime(editTime);

        Map<String,String> pMap= (Map<String, String>) req.getServletContext().getAttribute("pMap");
        String possibility=pMap.get(stage);
        t.setPossibility(possibility);

        boolean flag=tranService.changeStage(t);
        Map<String,Object> map=new HashMap<String, Object>();
        map.put("success",flag);
        map.put("t",t);

        PrintJson.printJsonObj(resp,map);




    }

    private void showHistoryListByTranId(HttpServletRequest req, HttpServletResponse resp) {
        TranService  tranService= (TranService) ServiceFactory.getService(new TranServiceImpl());
        String tranId=req.getParameter("tranId");
        List<TranHistory> thList=tranService.showHistoryListByTranId(tranId);
        Map<String,String> pMap= (Map<String, String>) req.getServletContext().getAttribute("pMap");
        for (TranHistory th:thList){
            String stage=th.getStage();
            String possibility=pMap.get(stage);
            th.setPossibility(possibility);
        }

        PrintJson.printJsonObj(resp,thList);

    }

    private void detail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TranService  tranService= (TranService) ServiceFactory.getService(new TranServiceImpl());
        String id=req.getParameter("id");
        Tran t=tranService.detail(id);
        //处理可能性
        String stage=t.getStage();
        Map<String,String> pMap= (Map<String, String>) req.getServletContext().getAttribute("pMap");
        String possibility=pMap.get(stage);
        t.setPossibility(possibility);

        req.setAttribute("t", t);
        req.getRequestDispatcher("/workbench/transaction/detail.jsp").forward(req, resp);

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
