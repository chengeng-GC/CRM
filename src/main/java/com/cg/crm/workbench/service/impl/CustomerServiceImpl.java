package com.cg.crm.workbench.service.impl;

import com.cg.crm.utils.SqlSessionUtil;
import com.cg.crm.vo.PaginationVO;
import com.cg.crm.workbench.dao.ContactsDao;
import com.cg.crm.workbench.dao.CustomerDao;
import com.cg.crm.workbench.dao.CustomerRemarkDao;
import com.cg.crm.workbench.dao.TranDao;
import com.cg.crm.workbench.domain.Contacts;
import com.cg.crm.workbench.domain.Customer;
import com.cg.crm.workbench.domain.CustomerRemark;
import com.cg.crm.workbench.domain.Tran;
import com.cg.crm.workbench.service.CustomerService;

import java.util.List;
import java.util.Map;

public class CustomerServiceImpl implements CustomerService {
   private CustomerDao customerDao= SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
   private CustomerRemarkDao customerRemarkDao =SqlSessionUtil.getSqlSession().getMapper(CustomerRemarkDao.class);
   private ContactsDao contactsDao =SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);
   private TranDao tranDao =SqlSessionUtil.getSqlSession().getMapper(TranDao.class);


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

   @Override
   public boolean save(Customer c) {
      System.out.println("进入save service层");
      boolean flag=true;
      int count=customerDao.add(c);
      if (count!=1){
         flag=false;
      }
      return flag;
   }

   @Override
   public Customer getUserListAndCustomer(String id) {
      System.out.println("进入getUserListAndCustomer service层");
      Customer c=customerDao.getById(id);
      return c;
   }

   @Override
   public boolean update(Customer c) {
      System.out.println("进入update service层");
      boolean flag=true;
      int count=customerDao.update(c);
      if (count!=1){
         flag=false;
      }
      return flag;
   }

   @Override
   public boolean delete(String[] ids) {
      System.out.println("进入delete service层");
      boolean flag=true;
      //查询出需要删除的备注的数量
      int count1 = customerRemarkDao.getCountByCids(ids);
      //删除备注，返回受到影响的条数（实际删除的数量）
      int count2=customerRemarkDao.deleteByCids(ids);
      if (count1!=count2){
         flag=false;
      }

      //查询出需要删除的交易的数量

      //删除交易

      //查询出需要删除的联系人的数量

      //删除联系人

      //删除线索
      int count7=customerDao.deleteByIds(ids);
      if (count7!=ids.length){
         flag=false;
      }
      System.out.println(flag);

      return flag;

   }

   @Override
   public Customer detail(String id) {
      System.out.println("进入detail service层");
      Customer c=customerDao.showById(id);
      return c;
   }

   @Override
   public List<CustomerRemark> showRemarkListByCid(String customerId) {
      System.out.println("进入showRemarkListByCid service层");
      List<CustomerRemark> crList=customerRemarkDao.showByCid(customerId);
      return crList;
   }

   @Override
   public boolean saveRemark(CustomerRemark cr) {
      System.out.println("进入saveRemark service层");
      boolean flag=true;
      int count=customerRemarkDao.add(cr);
      if (count!=1){
         flag=false;
      }
      return flag;
   }

   @Override
   public boolean deleteRemark(String id) {
      System.out.println("进入deleteRemark service层");
      boolean flag=true;
      int count=customerRemarkDao.deleteById(id);
      if (count!=1){
         flag=false;
      }
      return flag;

   }

   @Override
   public boolean updateRemark(CustomerRemark cr) {
      System.out.println("进入updateRemark service层");
      boolean flag=true;
      int count=customerRemarkDao.update(cr);
      if (count!=1){
         flag=false;
      }
      return flag;

   }
}
