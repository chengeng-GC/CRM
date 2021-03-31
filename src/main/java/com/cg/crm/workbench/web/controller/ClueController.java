package com.cg.crm.workbench.web.controller;

import com.cg.crm.settings.domain.User;
import com.cg.crm.settings.service.UserService;
import com.cg.crm.settings.service.impl.UserServiceImpl;
import com.cg.crm.utils.DateTimeUtil;
import com.cg.crm.utils.PrintJson;
import com.cg.crm.utils.ServiceFactory;
import com.cg.crm.utils.UUIDUtil;
import com.cg.crm.vo.PaginationVO;
import com.cg.crm.workbench.domain.Activity;
import com.cg.crm.workbench.domain.ActivityRemark;
import com.cg.crm.workbench.domain.Clue;
import com.cg.crm.workbench.service.ActivityService;
import com.cg.crm.workbench.service.ClueService;
import com.cg.crm.workbench.service.impl.ActivityServiceImpl;
import com.cg.crm.workbench.service.impl.ClueServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class ClueController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        //获取请求地址
        String path = req.getServletPath();
        System.out.println("1");
        //判断执行方法
        if ("/workbench/clue/getUserList.do".equals(path)) {
            getUserList(req, resp);
        } else if ("/workbench/clue/saveClue.do".equals(path)) {
            saveClue(req, resp);
        } else if ("/workbench/clue/pageList.do".equals(path)) {
            pageList(req, resp);
        } else if ("/workbench/clue/detail.do".equals(path)) {
            detail(req,resp);
        } else if ("/workbench/clue/showActivityListByCid.do".equals(path)) {
            showActivityListByCid(req,resp);
        } else if ("/workbench/clue/unbund.do".equals(path)) {
            unbund(req,resp);
        } else if ("/workbench/clue/showAcitivityListByNameExceptClueId.do".equals(path)) {
            showAcitivityListByNameExceptClueId(req,resp);
        } else if ("/workbench/clue/bund.do".equals(path)) {
            bund(req,resp);
        } else if ("/workbench/clue/showAcitivityListByName.do".equals(path)) {
            showAcitivityListByName(req,resp);
        } else if ("/workbench/clue/xxx.do".equals(path)) {
            //xxx(req,resp);
        }else if ("/workbench/clue/xxx.do".equals(path)) {
            //xxx(req,resp);
        }else if ("/workbench/clue/xxx.do".equals(path)) {
            //xxx(req,resp);
        }
    }

    private void showAcitivityListByName(HttpServletRequest req, HttpServletResponse resp) {
        ActivityService activityService= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        String name =req.getParameter("name");
        List<Activity> aList=activityService.getAcitivityListByName(name);
        PrintJson.printJsonObj(resp,aList);

    }

    private void bund(HttpServletRequest req, HttpServletResponse resp) {
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        String[] aids= req.getParameterValues("aid");
        String cid=req.getParameter("cid");
        Map<String,Object> map=new HashMap<String, Object>();
        map.put("cid",cid);
        map.put("aids",aids);
        boolean flag= clueService.bund(map);
        PrintJson.printJsonFlag(resp,flag);
    }

    private void showAcitivityListByNameExceptClueId(HttpServletRequest req, HttpServletResponse resp) {
        ActivityService activityService= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        String name =req.getParameter("name");
        String clueId=req.getParameter("clueId");
        Map<String,String> map=new HashMap<String, String>();
        map.put("name",name);
        map.put("clueId",clueId);
        List<Activity> aList=activityService.getAcitivityListByNameExceptClueId(map);
        PrintJson.printJsonObj(resp,aList);
    }

    private void unbund(HttpServletRequest req, HttpServletResponse resp) {
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        String id=req.getParameter("id");
       boolean flag= clueService.unbund(id);
       PrintJson.printJsonFlag(resp,flag);
    }

    private void showActivityListByCid(HttpServletRequest req, HttpServletResponse resp) {
        ActivityService activityService= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        String clueId=req.getParameter("clueId");
        List<Activity> alist= activityService.getActivityListByCid(clueId);
        PrintJson.printJsonObj(resp,alist);
    }

    private void detail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        String id=req.getParameter("id");
        Clue c= clueService.detail(id);
        req.setAttribute("c",c);
        req.getRequestDispatcher("/workbench/clue/detail.jsp").forward(req,resp);
    }

    private void pageList(HttpServletRequest req, HttpServletResponse resp) {
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        String fullname = req.getParameter("fullname");
        String owner = req.getParameter("owner");
        String company = req.getParameter("company");
        String phone = req.getParameter("phone");
        String mphone = req.getParameter("mphone");
        String state = req.getParameter("state");
        String source = req.getParameter("source");
        int pageNo= Integer.valueOf(req.getParameter("pageNo"));
        int pageSize= Integer.valueOf(req.getParameter("pageSize"));
        int skipCount=(pageNo-1)*pageSize;
        Map<String,Object> map=new HashMap<String, Object>();
        map.put("fullname",fullname);
        map.put("owner",owner);
        map.put("company",company);
        map.put("phone",phone);
        map.put("mphone",mphone);
        map.put("state",state);
        map.put("source",source);
        map.put("skipCount",skipCount);
        map.put("pageSize",pageSize);
        PaginationVO<Clue> vo=clueService.pageList(map);
        PrintJson.printJsonObj(resp,vo);
    }

    private void saveClue(HttpServletRequest req, HttpServletResponse resp) {
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        String id = UUIDUtil.getUUID();
        String fullname = req.getParameter("fullname");
        String appellation = req.getParameter("appellation");
        String owner = req.getParameter("owner");
        String company = req.getParameter("company");
        String job = req.getParameter("job");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String website = req.getParameter("website");
        String mphone = req.getParameter("mphone");
        String state = req.getParameter("state");
        String source = req.getParameter("source");
        String createBy = ((User) req.getSession().getAttribute("user")).getName();
        String createTime = DateTimeUtil.getSysTime();
        String description = req.getParameter("description");
        String contactSummary = req.getParameter("contactSummary");
        String nextContactTime = req.getParameter("nextContactTime");
        String address = req.getParameter("address");
        Clue c = new Clue();
        c.setAddress(address);
        c.setAppellation(appellation);
        c.setWebsite(website);
        c.setState(state);
        c.setSource(source);
        c.setPhone(phone);
        c.setOwner(owner);
        c.setNextContactTime(nextContactTime);
        c.setMphone(mphone);
        c.setJob(job);
        c.setId(id);
        c.setFullname(fullname);
        c.setEmail(email);
        c.setDescription(description);
        c.setCreateTime(createTime);
        c.setCreateBy(createBy);
        c.setContactSummary(contactSummary);
        c.setCompany(company);
        boolean flag = clueService.saveClue(c);
        PrintJson.printJsonFlag(resp, flag);
    }

    private void getUserList(HttpServletRequest req, HttpServletResponse resp) {
        UserService userService = (UserService) ServiceFactory.getService(new UserServiceImpl());
        List<User> ulist = userService.getUserList();
        PrintJson.printJsonObj(resp, ulist);
    }

}
