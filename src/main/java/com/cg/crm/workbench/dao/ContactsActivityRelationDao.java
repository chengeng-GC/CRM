package com.cg.crm.workbench.dao;

import com.cg.crm.workbench.domain.ContactsActivityRelation;

public interface ContactsActivityRelationDao {

    int add(ContactsActivityRelation contactsActivityRelation);

    int CountByCids(String[] ids);

    int deleteByCids(String[] ids);

    int deleteById(String id);
}
