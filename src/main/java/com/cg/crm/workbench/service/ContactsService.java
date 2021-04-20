package com.cg.crm.workbench.service;

import com.cg.crm.vo.PaginationVO;
import com.cg.crm.workbench.domain.Contacts;

import java.util.Map;

public interface ContactsService {
    PaginationVO<Contacts> pageList(Map<String, Object> map);

    boolean save(Contacts con, String customerName);

    boolean delete(String[] ids);

    Contacts getUserListAndContacts(String id);

    boolean update(Contacts con, String customerName);
}
