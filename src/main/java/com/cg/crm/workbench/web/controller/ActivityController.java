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
import com.cg.crm.workbench.service.ActivityService;
import com.cg.crm.workbench.service.impl.ActivityServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class ActivityController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        //获取请求地址
        String path=req.getServletPath();
        System.out.println("1");
        //判断执行方法
        if ("/workbench/activity/getUserList.do".equals(path)){
            getUserList(req,resp);
        }else if ("/workbench/activity/save.do".equals(path)){
            save(req,resp);
        }else if ("/workbench/activity/pageList.do".equals(path)){
            pageList(req,resp);
        }else if ("/workbench/activity/delete.do".equals(path)){
            delete(req,resp);
        }else if ("/workbench/activity/getUserListAndActivity.do".equals(path)){
            getUserListAndActivity(req,resp);
        }else if ("/workbench/activity/update.do".equals(path)){
            update(req,resp);
        }else if ("/workbench/activity/detail.do".equals(path)){
            detail(req,resp);
        }else if ("/workbench/activity/getRemarkListByAid.do".equals(path)){
            getRemarkListByAid(req,resp);
        }else if ("/workbench/activity/deleteRemark.do".equals(path)){
            deleteRemark(req,resp);
        }else if ("/workbench/activity/saveRemark.do".equals(path)){
            saveRemark(req,resp);
        }else if ("/workbench/activity/updateRemark.do".equals(path)){
            updateRemark(req,resp);
        }
    }

    private void updateRemark(HttpServletRequest req, HttpServletResponse resp) {
        ActivityService activityService= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        String id= req.getParameter("id");
        String noteContent=req.getParameter("noteContent");
        String editTime=DateTimeUtil.getSysTime();
        String editBy=((User)req.getSession().getAttribute("user")).getName();
        String editFlag="1";
        ActivityRemark ar=new ActivityRemark();
        ar.setId(id);
        ar.setNoteContent(noteContent);
        ar.setEditFlag(editFlag);
        ar.setEditTime(editTime);
        ar.setEditBy(editBy);
        boolean flag= activityService.updateRemark(ar);
        Map<String,Object> map=new HashMap<String, Object>();
        map.put("success",flag);
        map.put("ar",ar);
        PrintJson.printJsonObj(resp,map);
    }

    private void saveRemark(HttpServletRequest req, HttpServletResponse resp) {
        ActivityService activityService= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
       String id=UUIDUtil.getUUID();
       String noteContent=req.getParameter("noteContent");
       String createTime=DateTimeUtil.getSysTime();
       String createBy=((User)req.getSession().getAttribute("user")).getName();
       String editFlag="0";
       String activityId=req.getParameter("activityId");
       ActivityRemark ar=new ActivityRemark();
       ar.setId(id);
       ar.setNoteContent(noteContent);
       ar.setCreateTime(createTime);
       ar.setCreateBy(createBy);
       ar.setEditFlag(editFlag);
       ar.setActivityId(activityId);
       boolean flag= activityService.saveRemark(ar);
       Map<String,Object> map=new HashMap<String, Object>();
       map.put("success",flag);
       map.put("ar",ar);
       PrintJson.printJsonObj(resp,map);
    }

    private void deleteRemark(HttpServletRequest req, HttpServletResponse resp) {
        ActivityService activityService= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        String id= req.getParameter("id");
       boolean flag= activityService.deleteRemark(id);
       PrintJson.printJsonFlag(resp,flag);
    }

    private void getRemarkListByAid(HttpServletRequest req, HttpServletResponse resp) {
        ActivityService activityService= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        String activityId= req.getParameter("activityId");
        List<ActivityRemark> arList=activityService.getRemarkListByAid(activityId);
        PrintJson.printJsonObj(resp,arList);

    }

    private void detail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        ActivityService activityService= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        String id= req.getParameter("id");
        Activity a=activityService.detail(id);
        req.setAttribute("a",a);
        req.getRequestDispatcher("/workbench/activity/detail.jsp").forward(req,resp);
    }

    private void update(HttpServletRequest req, HttpServletResponse resp) {
        ActivityService activityService= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        String id= req.getParameter("id");
        String owner=req.getParameter("owner");
        String name=req.getParameter("name");
        String startDate=req.getParameter("startDate");
        String endDate=req.getParameter("endDate");
        String cost=req.getParameter("cost");
        String description =req.getParameter("description");
        //修改时间：当前系统时间
        String editTime= DateTimeUtil.getSysTime();
        //修改人，当前登录用户
        String editBy=((User)req.getSession().getAttribute("user")).getName();

        Activity a=new Activity();
        a.setId(id);
        a.setOwner(owner);
        a.setName(name);
        a.setStartDate(startDate);
        a.setEndDate(endDate);
        a.setCost(cost);
        a.setDescription(description);
        a.setEditTime(editTime);
        a.setEditBy(editBy);
        boolean flag= activityService.update(a);
        PrintJson.printJsonFlag(resp,flag);
    }

    private void getUserListAndActivity(HttpServletRequest req, HttpServletResponse resp) {
        String id=req.getParameter("id");
        UserService userService= (UserService) ServiceFactory.getService(new UserServiceImpl());
        List<User> ulist=userService.getUserList();
        ActivityService activityService= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        Activity a=activityService.getById(id);
        Map<String,Object> map=new HashMap<String, Object>();
        map.put("ulist",ulist);
        map.put("a",a);
        PrintJson.printJsonObj(resp,map);
    }

    private void delete(HttpServletRequest req, HttpServletResponse resp) {
        ActivityService activityService= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        String ids[]=req.getParameterValues("id");
       boolean flag= activityService.delete(ids);
       PrintJson.printJsonFlag(resp,flag);
    }

    private void pageList(HttpServletRequest req, HttpServletResponse resp) {
        ActivityService activityService= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
       int pageNo= Integer.valueOf(req.getParameter("pageNo"));
       int pageSize= Integer.valueOf(req.getParameter("pageSize"));
       String name =req.getParameter("name");
       String owner=req.getParameter("owner");
       String startDate=req.getParameter("startDate");
       String endDate=req.getParameter("endDate");
       //计算出略过的记录数
        int skipCount=(pageNo-1)*pageSize;

        Map<String,Object> map=new HashMap<String, Object>();
        map.put("name",name);
        map.put("owner",owner);
        map.put("startDate",startDate);
        map.put("endDate",endDate);
        map.put("skipCount",skipCount);
        map.put("pageSize",pageSize);

       PaginationVO<Activity> vo= activityService.pageList(map);
       PrintJson.printJsonObj(resp,vo);
    }

    private void save(HttpServletRequest req, HttpServletResponse resp) {
        ActivityService activityService= (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        String id= UUIDUtil.getUUID();
        String owner=req.getParameter("owner");
        String name=req.getParameter("name");
        String startDate=req.getParameter("startDate");
        String endDate=req.getParameter("endDate");
        String cost=req.getParameter("cost");
        String description =req.getParameter("description");
        //创建时间：当前系统时间
        String createTime= DateTimeUtil.getSysTime();
        //创建人，当前登录用户
        String createBy=((User)req.getSession().getAttribute("user")).getName();

        Activity a=new Activity();
        a.setId(id);
        a.setOwner(owner);
        a.setName(name);
        a.setStartDate(startDate);
        a.setEndDate(endDate);
        a.setCost(cost);
        a.setDescription(description);
        a.setCreateTime(createTime);
        a.setCreateBy(createBy);
        boolean flag= activityService.save(a);
        PrintJson.printJsonFlag(resp,flag);
    }

    private void getUserList(HttpServletRequest req, HttpServletResponse resp) {
        UserService userService= (UserService) ServiceFactory.getService(new UserServiceImpl());
        List<User> ulist=userService.getUserList();
        PrintJson.printJsonObj(resp,ulist);
    }


}
