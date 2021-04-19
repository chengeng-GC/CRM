package com.cg.crm.workbench.dao;

import com.cg.crm.workbench.domain.CustomerRemark;

import java.util.List;

public interface CustomerRemarkDao {

    int add(CustomerRemark customerRemark);

    int getCountByCids(String[] ids);

    int deleteByCids(String[] ids);

    List<CustomerRemark> showByCid(String customerId);

    int deleteById(String id);
}
