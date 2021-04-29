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

    List<Tran> pageList(Map<String, Object> map);

    int countPageList(Map<String, Object> map);

    int deleteByIds(String[] ids);

    Tran showCusById(String id);

    int update(Tran t);

    List<Tran> showOrderByConid(String contactsId);

    String[] getIdByConids(String[] ids);

    List<Tran> showOrderByCusid(String customerId);

    String[] getIdByCusids(String[] ids);
}
