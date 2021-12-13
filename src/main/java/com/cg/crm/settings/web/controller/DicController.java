package com.cg.crm.settings.web.controller;

import com.cg.crm.settings.domain.DicType;
import com.cg.crm.settings.domain.DicValue;
import com.cg.crm.settings.domain.User;
import com.cg.crm.settings.service.DicService;
import com.cg.crm.settings.service.impl.DicServiceImpl;
import com.cg.crm.utils.PrintJson;
import com.cg.crm.utils.ServiceFactory;
import com.cg.crm.vo.PaginationVO;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class DicController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        //获取请求地址
        String path=req.getServletPath();
        //判断执行方法
        if ("/settings/dic/pageListType.do".equals(path)){
            pageListType(req,resp);
        }else if ("/settings/dic/pageListValue.do".equals(path)){
            pageListValue(req,resp);
        }else if ("/settings/dic/xxx.do".equals(path)){
            //xxx(req,resp);
        }

    }

    private void pageListValue(HttpServletRequest req, HttpServletResponse resp) {
        DicService dicService=(DicService) ServiceFactory.getService(new DicServiceImpl());
        int pageNo= Integer.valueOf(req.getParameter("pageNo"));
        int pageSize= Integer.valueOf(req.getParameter("pageSize"));
        String typeCode=req.getParameter("typeCode");
        //计算出略过的记录数
        int skipCount=(pageNo-1)*pageSize;
        Map<String,Object> map=new HashMap<String, Object>();
        map.put("skipCount",skipCount);
        map.put("pageSize",pageSize);
        map.put("typeCode",typeCode);
        PaginationVO<DicValue> vo= dicService.pageListValue(map);
        PrintJson.printJsonObj(resp,vo);
    }

    private void pageListType(HttpServletRequest req, HttpServletResponse resp) {
        DicService dicService=(DicService) ServiceFactory.getService(new DicServiceImpl());
        int pageNo= Integer.valueOf(req.getParameter("pageNo"));
        int pageSize= Integer.valueOf(req.getParameter("pageSize"));
        //计算出略过的记录数
        int skipCount=(pageNo-1)*pageSize;
        Map<String,Object> map=new HashMap<String, Object>();
        map.put("skipCount",skipCount);
        map.put("pageSize",pageSize);
        PaginationVO<DicType> vo= dicService.pageListType(map);
        PrintJson.printJsonObj(resp,vo);
    }


}
