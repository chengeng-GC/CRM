package com.cg.crm.workbench.dao;

import com.cg.crm.workbench.domain.ActivityRemark;

public interface ActivityRemarkDao {
    int getCountByAids(String[] ids);

    int deleteByAids(String[] ids);

    int deleteById(String id);

    int insert(ActivityRemark ar);

    int update(ActivityRemark ar);
}
