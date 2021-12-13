package com.cg.crm.settings.service.impl;

import com.cg.crm.exception.LoginException;
import com.cg.crm.settings.dao.UserDao;
import com.cg.crm.settings.domain.User;
import com.cg.crm.settings.service.UserService;
import com.cg.crm.utils.DateTimeUtil;
import com.cg.crm.utils.SqlSessionUtil;
import com.cg.crm.vo.PaginationVO;
import com.cg.crm.workbench.domain.Activity;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class UserServiceImpl implements UserService {
    private UserDao userDao= SqlSessionUtil.getSqlSession().getMapper(UserDao.class);

    @Override
    public User login(String loginAct, String loginPwd, String ip) throws LoginException {
//        将loginAct和loginPwd保存成为map
        Map<String,String> map=new HashMap<String, String>();
        map.put("loginAct",loginAct);
        map.put("loginPwd",loginPwd);
//      service层工作并返回数据
//      login(Map<String.Sting>)
        User user=userDao.login(map);
        if (user==null){
            throw new LoginException("账号密码错误");
        }
//      如果程序能够执行到该行,说明账号密码正确

//      User 从user对象中取出expireTime,lockState,allowIps
        String expireTime=user.getExpireTime();
        String lockState=user.getLockState();
        String allowIps=user.getAllowIps();
//      验证expireTime
//      使用工具类获取当前时间
        String currentTime= DateTimeUtil.getSysTime();
        if (expireTime.compareTo(currentTime)<0){
            throw new LoginException("账号已失效");
        }
//      验证lockState
        if ("0".equals(lockState)){
            throw new LoginException("账号已锁定");
        }
//      验证ip地址（通过allowIps来验证）

        if (!allowIps.contains(ip)){
            throw new LoginException("ip地址受限");
        }

//      返回user对象
        return user;
    }

    @Override
    public List<User> getUserList() {
        List<User> ulist=userDao.getUserList();
        return  ulist;
    }

    @Override
    public PaginationVO<User> pageList(Map<String, Object> map) {
        //取得total
        int total=userDao.getTotalByCondition(map);
        //取得dataList
        List<User> alist=userDao.getUserListByCondition(map);
        //将total和dataList封装到vo中
        PaginationVO<User> vo=new PaginationVO<User>();
        vo.setTotal(total);
        vo.setDataList(alist);
        //将vo返回
        return vo;
    }

    @Override
    public boolean save(User u) {
        boolean flag= true;
        int count= userDao.save(u);
        if (count!=1){
            flag=false;
        }
        return flag;
    }

    @Override
    public boolean delete(String[] ids) {
        boolean flag=true;
        int count=userDao.delete(ids);
        if (count!=ids.length){
            flag=false;
        }
        return flag;
    }


}
