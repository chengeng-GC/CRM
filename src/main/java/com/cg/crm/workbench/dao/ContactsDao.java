package com.cg.crm.workbench.dao;

import com.cg.crm.workbench.domain.Contacts;

import java.util.List;
import java.util.Map;

public interface ContactsDao {

    int add(Contacts contacts);

    List<Contacts> pageList(Map<String, Object> map);

    int countPageList(Map<String, Object> map);

    int deleteByIds(String[] ids);

    Contacts showCusNameById(String id);

    int update(Contacts con);

    Contacts detail(String id);

    List<Contacts> getLikeName(String name);

    Contacts getById(String contactsId);

    List<Contacts> showOrderByCusid(String customerId);

    String[] getIdByCusids(String[] ids);
}
