package com.cg.crm.workbench.dao;

import com.cg.crm.workbench.domain.TranHistory;

import java.util.List;

public interface TranHistoryDao {

    int add(TranHistory tranHistory);

    List<TranHistory> getListByTranId(String tranId);

    int countByTids(String[] ids);

    int deleteByTids(String[] ids);
}
