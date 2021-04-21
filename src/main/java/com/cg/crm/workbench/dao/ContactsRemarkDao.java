package com.cg.crm.workbench.dao;

import com.cg.crm.workbench.domain.ContactsRemark;

import java.util.List;

public interface ContactsRemarkDao {

    int add(ContactsRemark contactsRemark);

    int CountByCids(String[] ids);

    int deleteByCids(String[] ids);

    List<ContactsRemark> showOrderByCid(String contactsId);

    int deleteById(String id);

    int update(ContactsRemark cr);
}
