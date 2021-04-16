package com.cg.crm.workbench.dao;

import com.cg.crm.workbench.domain.Customer;

import java.util.List;
import java.util.Map;

public interface CustomerDao {

    Customer getByName(String company);

    int add(Customer customer);

    List<String> getCustomerName(String name);

    List<Customer> pageList(Map<String, Object> map);

    int countPageList(Map<String, Object> map);
}
