package com.cg.crm.workbench.service;

import com.cg.crm.vo.PaginationVO;
import com.cg.crm.workbench.domain.Contacts;
import com.cg.crm.workbench.domain.Customer;
import com.cg.crm.workbench.domain.CustomerRemark;
import com.cg.crm.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface CustomerService {
    List<String> getCustomerName(String name);

    PaginationVO<Customer> pageList(Map<String, Object> map);

    boolean save(Customer c);

    Customer getUserListAndCustomer(String id);

    boolean update(Customer c);

    boolean delete(String[] ids);

    Customer detail(String id);

    List<CustomerRemark> showRemarkListByCid(String customerId);

    boolean saveRemark(CustomerRemark cr);

    boolean deleteRemark(String id);

    boolean updateRemark(CustomerRemark cr);

    List<Tran> showTranListByCid(String customerId);

    List<Contacts> showContactsListByCid(String customerId);
}
