package com.cg.crm.workbench.dao;

public interface TranRemarkDao {

    int countByTids(String[] ids);

    int deleteByTids(String[] ids);
}
