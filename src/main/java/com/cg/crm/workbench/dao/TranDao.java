package com.cg.crm.workbench.dao;

import com.cg.crm.workbench.domain.Tran;

public interface TranDao {

    int add(Tran t);

    Tran detail(String id);
}
