package com.cg.crm.workbench.service.impl;

import com.cg.crm.utils.SqlSessionUtil;
import com.cg.crm.vo.PaginationVO;
import com.cg.crm.workbench.dao.*;
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
   private TranHistoryDao tranHistoryDao = SqlSessionUtil.getSqlSession().getMapper(TranHistoryDao.class);
   private TranRemarkDao tranRemarkDao = SqlSessionUtil.getSqlSession().getMapper(TranRemarkDao.class);
   private ContactsRemarkDao contactsRemarkDao= SqlSessionUtil.getSqlSession().getMapper(ContactsRemarkDao.class);
   private ContactsActivityRelationDao contactsActivityRelationDao= SqlSessionUtil.getSqlSession().getMapper(ContactsActivityRelationDao.class);


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

      //删除交易备注
      String[] tids=tranDao.getIdByCusids(ids);
      if (tids.length!=0) {
         count1 = tranRemarkDao.countByTids(tids);
         count2 = tranRemarkDao.deleteByTids(tids);
         if (count1 != count2) {
            flag = false;
         }

         //删除交易阶段历史
         int count3 = tranHistoryDao.countByTids(tids);
         int count4 = tranHistoryDao.deleteByTids(tids);
         if (count3 != count4) {
            flag = false;
         }

         //删除交易
         int count = tranDao.deleteByIds(tids);
         if (count != tids.length) {
            flag = false;
         }
      }

      //删除联系人备注
      String[] cids=contactsDao.getIdByCusids(ids);
      if (cids.length!=0) {
         count1 = contactsRemarkDao.CountByCids(cids);
         count2 = contactsRemarkDao.deleteByCids(cids);
         if (count1 != count2) {
            flag = false;
         }


         //删除联系人交易备注
         String[] ctids = tranDao.getIdByConids(cids);
         if (ctids.length!=0) {
            count1 = tranRemarkDao.countByTids(ctids);
            count2 = tranRemarkDao.deleteByTids(ctids);
            if (count1 != count2) {
               flag = false;
            }

            //删除联系人交易阶段历史
            int count3 = tranHistoryDao.countByTids(ctids);
            int count4 = tranHistoryDao.deleteByTids(ctids);
            if (count3 != count4) {
               flag = false;
            }

            //删除联系人交易
            int count = tranDao.deleteByIds(ctids);
            if (count != ctids.length) {
               flag = false;
            }
         }

         //删除联系人市场活动关系
         int count5 = contactsActivityRelationDao.CountByCids(cids);
         int count6 = contactsActivityRelationDao.deleteByCids(cids);
         if (count5 != count6) {
            flag = false;
         }

         //删除联系人
         int count = contactsDao.deleteByIds(cids);
         if (count != cids.length) {
            flag = false;
         }
      }

      //删除客户
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

   @Override
   public List<Tran> showTranListByCid(String customerId) {
      System.out.println("进入showTranListByCid service层");
      List<Tran>  tList=tranDao.showOrderByCusid(customerId);
      return tList;
   }

   @Override
   public List<Contacts> showContactsListByCid(String customerId) {
      System.out.println("进入showContactsListByCid service层");
      List<Contacts>  cList=contactsDao.showOrderByCusid(customerId);
      return cList;
   }
}
