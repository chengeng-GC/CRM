package com.cg.crm.workbench.service;

import com.cg.crm.vo.PaginationVO;
import com.cg.crm.workbench.domain.Activity;
import com.cg.crm.workbench.domain.ActivityRemark;

import java.util.List;
import java.util.Map;

public interface ActivityService {
    boolean save(Activity a);

    PaginationVO<Activity> pageList(Map<String, Object> map);

    boolean delete(String[] ids);

    Activity getById(String id);

    boolean update(Activity a);

    Activity detail(String id);

    List<ActivityRemark> getRemarkListByAid(String activityId);

    boolean deleteRemark(String id);

    boolean saveRemark(ActivityRemark ar);

    boolean updateRemark(ActivityRemark ar);

    List<Activity> getActivityListByCid(String clueId);

    List<Activity> getAcitivityListByNameExceptClueId(Map<String,String> map);

    List<Activity> getAcitivityListByName(String name);

    List<Activity> showActivityListByConid(String contactsId);

    List<Activity> showAcitivityListByNameExceptConid(Map<String, String> map);
}
