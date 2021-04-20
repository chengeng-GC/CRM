package com.cg.crm.workbench.service.impl;

import com.cg.crm.utils.DateTimeUtil;
import com.cg.crm.utils.SqlSessionUtil;
import com.cg.crm.utils.UUIDUtil;
import com.cg.crm.vo.PaginationVO;
import com.cg.crm.workbench.dao.ContactsActivityRelationDao;
import com.cg.crm.workbench.dao.ContactsDao;
import com.cg.crm.workbench.dao.ContactsRemarkDao;
import com.cg.crm.workbench.dao.CustomerDao;
import com.cg.crm.workbench.domain.Contacts;
import com.cg.crm.workbench.domain.Customer;
import com.cg.crm.workbench.service.ContactsService;

import java.util.List;
import java.util.Map;

public class ContactsServiceImpl implements ContactsService {
    private ContactsDao contactsDao= SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);
    private ContactsRemarkDao contactsRemarkDao= SqlSessionUtil.getSqlSession().getMapper(ContactsRemarkDao.class);
    private ContactsActivityRelationDao contactsActivityRelationDao= SqlSessionUtil.getSqlSession().getMapper(ContactsActivityRelationDao.class);
    private CustomerDao customerDao= SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);


    @Override
    public PaginationVO<Contacts> pageList(Map<String, Object> map) {
        System.out.println("进入pageList service层");
        PaginationVO<Contacts> vo=new PaginationVO<Contacts>();
        List<Contacts> cList=contactsDao.pageList(map);
        int total=contactsDao.countPageList(map);
        vo.setDataList(cList);
        vo.setTotal(total);
        return vo;
    }

    @Override
    public boolean save(Contacts con, String customerName) {
        System.out.println("进入save service层");
        boolean flag=true;
        //根据customerName在客户表进行精确查询
        Customer cus=customerDao.getByName(customerName);
        // 如果没有，客户表新建一条客户信息
       if (cus==null){
           cus=new Customer();
           cus.setId(UUIDUtil.getUUID());
           cus.setOwner(con.getOwner());
           cus.setName(customerName);
           cus.setCreateBy(con.getCreateBy());
           cus.setCreateTime(DateTimeUtil.getSysTime());
           cus.setContactSummary(con.getContactSummary());
           cus.setNextContactTime(con.getNextContactTime());
           cus.setDescription(con.getDescription());
           cus.setAddress(con.getAddress());
           int count1=customerDao.add(cus);
           if (count1!=1){
               flag=false;
           }
       }
        //取出这个客户的id
       String customerId= cus.getId();
       con.setCustomerId(customerId);

       int count2=contactsDao.add(con);
        if (count2!=1){
            flag=false;
        }

        return flag;

    }

    @Override
    public boolean delete(String[] ids) {
        System.out.println("进入delete service层");
        boolean flag=true;
        int count=contactsDao.deleteByIds(ids);
        if (count!=ids.length){
            flag=false;
        }
        return flag;
    }

    @Override
    public Contacts getUserListAndContacts(String id) {
        System.out.println("进入getUserListAndContacts service层");
        Contacts c=contactsDao.showCusNameById(id);
        return c;
    }

    @Override
    public boolean update(Contacts con, String customerName) {
        System.out.println("进入update service层");
        boolean flag=true;
        //根据customerName在客户表进行精确查询
        Customer cus=customerDao.getByName(customerName);
        // 如果没有，客户表新建一条客户信息
        if (cus==null){
            cus=new Customer();
            cus.setId(UUIDUtil.getUUID());
            cus.setOwner(con.getOwner());
            cus.setName(customerName);
            cus.setCreateBy(con.getCreateBy());
            cus.setCreateTime(DateTimeUtil.getSysTime());
            cus.setContactSummary(con.getContactSummary());
            cus.setNextContactTime(con.getNextContactTime());
            cus.setDescription(con.getDescription());
            cus.setAddress(con.getAddress());
            int count1=customerDao.add(cus);
            if (count1!=1){
                flag=false;
            }
        }
        //取出这个客户的id
        String customerId= cus.getId();
        con.setCustomerId(customerId);

        int count2=contactsDao.update(con);
        if (count2!=1){
            flag=false;
        }

        return flag;
    }
}
