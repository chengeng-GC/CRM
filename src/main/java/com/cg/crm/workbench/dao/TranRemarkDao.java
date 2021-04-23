package com.cg.crm.workbench.dao;

import com.cg.crm.workbench.domain.TranRemark;

import java.util.List;

public interface TranRemarkDao {

    int countByTids(String[] ids);

    int deleteByTids(String[] ids);

    List<TranRemark> showOrderByTid(String tranId);

    int deleteById(String id);

    int update(TranRemark tr);

    int insert(TranRemark tr);
}
