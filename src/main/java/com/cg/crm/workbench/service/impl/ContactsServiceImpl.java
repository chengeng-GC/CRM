package com.cg.crm.workbench.service.impl;

import com.cg.crm.utils.DateTimeUtil;
import com.cg.crm.utils.SqlSessionUtil;
import com.cg.crm.utils.UUIDUtil;
import com.cg.crm.vo.PaginationVO;
import com.cg.crm.workbench.dao.ContactsActivityRelationDao;
import com.cg.crm.workbench.dao.ContactsDao;
import com.cg.crm.workbench.dao.ContactsRemarkDao;
import com.cg.crm.workbench.dao.CustomerDao;
import com.cg.crm.workbench.domain.*;
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
        //删除备注
        int count1=contactsRemarkDao.CountByCids(ids);
        int count2=contactsRemarkDao.deleteByCids(ids);
        if (count1!=count2){
            flag=false;
        }
        //删除交易


        //删除市场活动关系
        int count5=contactsActivityRelationDao.CountByCids(ids);
        int count6=contactsActivityRelationDao.deleteByCids(ids);
        if (count5!=count6){
            flag=false;
        }

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

    @Override
    public Contacts detail(String id) {
        System.out.println("进入detail service层");
        Contacts c=contactsDao.detail(id);
        return c;
    }

    @Override
    public List<ContactsRemark> showRemarkListByCid(String contactsId) {
        System.out.println("进入showRemarkListByCid service层");
        List<ContactsRemark> crList=contactsRemarkDao.showOrderByCid(contactsId);
        return crList;
    }

    @Override
    public boolean deleteRemark(String id) {
        System.out.println("进入deleteRemark service层");
        boolean flag=true;
        int count=contactsRemarkDao.deleteById(id);
        if (count!=1){
            flag=false;
        }

        return flag;
    }

    @Override
    public boolean saveRemark(ContactsRemark cr) {
        System.out.println("进入saveRemark service层");
        boolean flag=true;
        int count=contactsRemarkDao.add(cr);
        if (count!=1){
            flag=false;
        }
        return flag;
    }

    @Override
    public boolean updateRemark(ContactsRemark cr) {
        System.out.println("进入updateRemark service层");
        boolean flag=true;
        int count=contactsRemarkDao.update(cr);
        if (count!=1){
            flag=false;
        }
        return flag;

    }

    @Override
    public boolean unbund(String id) {
        System.out.println("进入unbund service层");
        boolean flag = true;
        int count = contactsActivityRelationDao.deleteById(id);
        if (count != 1) {
            flag = false;
        }
        return flag;
    }

    @Override
    public boolean bund(Map<String, Object> map) {
        boolean flag = true;
        String[] aids = (String[]) map.get("aids");
        String contactsId = (String) map.get("contactsId");
        ContactsActivityRelation r = new ContactsActivityRelation();
        r.setContactsId(contactsId);
        for (String aid : aids) {
            r.setActivityId(aid);
            r.setId(UUIDUtil.getUUID());
            int count = contactsActivityRelationDao.add(r);
            if (count != 1) {
                flag = false;
            }
        }

        return flag;
    }


}
