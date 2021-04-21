package com.cg.crm.workbench.service.impl;

import com.cg.crm.utils.SqlSessionUtil;
import com.cg.crm.vo.PaginationVO;
import com.cg.crm.workbench.dao.ActivityDao;
import com.cg.crm.workbench.dao.ActivityRemarkDao;
import com.cg.crm.workbench.dao.ClueActivityRelationDao;
import com.cg.crm.workbench.domain.Activity;
import com.cg.crm.workbench.domain.ActivityRemark;
import com.cg.crm.workbench.service.ActivityService;

import java.util.List;
import java.util.Map;

public class ActivityServiceImpl implements ActivityService {
private ActivityDao activityDao= SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);
private ActivityRemarkDao activityRemarkDao=SqlSessionUtil.getSqlSession().getMapper(ActivityRemarkDao.class);
private ClueActivityRelationDao clueActivityRelationDao=SqlSessionUtil.getSqlSession().getMapper(ClueActivityRelationDao.class);
    public boolean save(Activity a) {
        boolean flag= true;
        int count= activityDao.save(a);
        if (count!=1){
            flag=false;
        }
        return flag;
    }

    @Override
    public PaginationVO<Activity> pageList(Map<String, Object> map) {
        //取得total
        int total=activityDao.getTotalByCondition(map);
        //取得dataList
        List<Activity> alist=activityDao.getActivityListByCondition(map);
        //将total和dataList封装到vo中
        PaginationVO<Activity> vo=new PaginationVO<Activity>();
        vo.setTotal(total);
        vo.setDataList(alist);
        //将vo返回
        return vo;
    }

    @Override
    public boolean delete(String[] ids) {
        boolean flag=true;
        //查询出需要删除的备注的数量
        int count1 = activityRemarkDao.getCountByAids(ids);
        //删除备注，返回受到影响的条数（实际删除的数量）
        int count2=activityRemarkDao.deleteByAids(ids);
        if (count1!=count2){
            flag=false;
        }
        //删除市场活动
        int count3=activityDao.delete(ids);
        if (count3!=ids.length){
            flag=false;
        }
        return flag;
    }

    @Override
    public Activity getById(String id) {
        Activity a= activityDao.getById(id);
        return a;
    }

    @Override
    public boolean update(Activity a) {
        boolean flag= true;
        int count= activityDao.update(a);
        if (count!=1){
            flag=false;
        }
        return flag;
    }

    @Override
    public Activity detail(String id) {
        Activity a= activityDao.detail(id);
        return a;
    }

    @Override
    public List<ActivityRemark> getRemarkListByAid(String activityId) {
       List<ActivityRemark> arList= activityDao.getRemarkListByAid(activityId);
        return arList;
    }

    @Override
    public boolean deleteRemark(String id) {
        boolean flag=true;
        int count =activityRemarkDao.deleteById(id);
        if (count!=1){
            flag=false;
        }
        return flag;
    }

    @Override
    public boolean saveRemark(ActivityRemark ar) {
        boolean flag=true;
        int count =activityRemarkDao.insert(ar);
        if (count!=1){
            flag=false;
        }
        return flag;
    }

    @Override
    public boolean updateRemark(ActivityRemark ar) {
        boolean flag=true;
        int count =activityRemarkDao.update(ar);
        if (count!=1){
            flag=false;
        }
        return flag;
    }

    @Override
    public List<Activity> getActivityListByCid(String clueId) {

        List<Activity> aList=activityDao.getActivityListByCid(clueId);
        return aList;
    }

    @Override
    public List<Activity> getAcitivityListByNameExceptClueId(Map<String,String> map) {
        List<Activity> aList=activityDao.getAcitivityListByNameExceptClueId(map);
        return aList;
    }

    @Override
    public List<Activity> getAcitivityListByName(String name) {
        List<Activity> aList=activityDao.getAcitivityListByName(name);
        return aList;
    }

    @Override
    public List<Activity> showActivityListByConid(String contactsId) {
        System.out.println("进入showActivityListByConid service层");
        List<Activity> aList=activityDao.showActivityListByConid(contactsId);
        return aList;
    }

    @Override
    public List<Activity> showAcitivityListByNameExceptConid(Map<String, String> map) {
        System.out.println("进入showAcitivityListByNameExceptConid service层");
        List<Activity> aList=activityDao.showAcitivityListByNameExceptConid(map);
        return aList;
    }
}
