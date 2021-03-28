package com.cg.crm.web.listener;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

public class SysInitListener implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent event) {
    //该方法是用来监听上下文域对象的方法，当服务器启动，上下文域对象创建对象创建完毕后，马上执行该方法
    //event:该参数能够取得监听的对象
    //现在监听的是上下文域对象
        ServletContext application=event.getServletContext();
        //取数据字典

       // application.setAttribute(key,数据字典);
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) {

    }
}
