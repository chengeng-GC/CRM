package com.cg.crm.web.listener;

import com.cg.crm.settings.domain.DicValue;
import com.cg.crm.settings.service.DicService;
import com.cg.crm.settings.service.impl.DicServiceImpl;
import com.cg.crm.utils.ServiceFactory;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class SysInitListener implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent event) {
    //该方法是用来监听上下文域对象的方法，当服务器启动，上下文域对象创建对象创建完毕后，马上执行该方法
    //event:该参数能够取得监听的对象
    //现在监听的是上下文域对象
        ServletContext application=event.getServletContext();
        //取数据字典
        DicService dicService= (DicService) ServiceFactory.getService(new DicServiceImpl());
        //管业务层要7个List，用一个map装7个List
        Map<String, List<DicValue>> map=dicService.getAll();
        Set<String> set=map.keySet();
        for (String key:set){
            application.setAttribute(key,map.get(key));
        }

    }

    @Override
    public void contextDestroyed(ServletContextEvent event) {

    }
}
