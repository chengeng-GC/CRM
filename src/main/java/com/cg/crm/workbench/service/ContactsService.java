package com.cg.crm.workbench.service;

import com.cg.crm.vo.PaginationVO;
import com.cg.crm.workbench.domain.Contacts;
import com.cg.crm.workbench.domain.ContactsRemark;

import java.util.List;
import java.util.Map;

public interface ContactsService {
    PaginationVO<Contacts> pageList(Map<String, Object> map);

    boolean save(Contacts con, String customerName);

    boolean delete(String[] ids);

    Contacts getUserListAndContacts(String id);

    boolean update(Contacts con, String customerName);

    Contacts detail(String id);


    List<ContactsRemark> showRemarkListByCid(String contactsId);

    boolean deleteRemark(String id);

    boolean saveRemark(ContactsRemark cr);

    boolean updateRemark(ContactsRemark cr);

    boolean unbund(String id);

    boolean bund(Map<String, Object> map);
}
