package com.cg.crm.workbench.dao;

import com.cg.crm.workbench.domain.Customer;

import java.util.List;

public interface CustomerDao {

    Customer getByName(String company);

    int add(Customer customer);

    List<String> getCustomerName(String name);
}
