package com.cg.crm.workbench.service.impl;

import com.cg.crm.utils.ServiceFactory;
import com.cg.crm.utils.SqlSessionUtil;
import com.cg.crm.vo.PaginationVO;
import com.cg.crm.workbench.dao.CustomerDao;
import com.cg.crm.workbench.dao.CustomerRemarkDao;
import com.cg.crm.workbench.domain.Customer;
import com.cg.crm.workbench.service.CustomerService;

import java.util.List;
import java.util.Map;

public class CustomerServiceImpl implements CustomerService {
   private CustomerDao customerDao= SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
   private CustomerRemarkDao customerRemarkDao =SqlSessionUtil.getSqlSession().getMapper(CustomerRemarkDao.class);

   @Override
   public List<String> getCustomerName(String name) {
      List<String> sList=customerDao.getCustomerName(name);
      return sList;
   }

   @Override
   public PaginationVO<Customer> pageList(Map<String, Object> map) {
      System.out.println("进入pageList service层");

      PaginationVO<Customer> vo=new PaginationVO<Customer>();
      List<Customer> cList=customerDao.pageList(map);
      int total=customerDao.countPageList(map);
      vo.setDataList(cList);
      vo.setTotal(total);
      return vo;
   }
}
