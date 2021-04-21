package com.cg.crm.workbench.dao;

import com.cg.crm.workbench.domain.Activity;
import com.cg.crm.workbench.domain.ActivityRemark;

import java.util.List;
import java.util.Map;

public interface ActivityDao {
    int save(Activity a);

    List<Activity> getActivityListByCondition(Map<String, Object> map);


    int getTotalByCondition(Map<String, Object> map);

    int delete(String[] ids);

    Activity getById(String id);

    int update(Activity a);

    Activity detail(String id);

    List<ActivityRemark> getRemarkListByAid(String activityId);

    List<Activity> getActivityListByCid(String clueId);

    List<Activity> getAcitivityListByNameExceptClueId(Map<String,String> map);

    List<Activity> getAcitivityListByName(String name);

    List<Activity> showActivityListByConid(String contactsId);

    List<Activity> showAcitivityListByNameExceptConid(Map<String, String> map);
}
