package com.cg.crm.workbench.dao;

import com.cg.crm.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface TranDao {

    int add(Tran t);

    Tran detail(String id);

    int changeStage(Tran t);

    int getTotal();

    List<Map<String, Object>> getCharts();
}
