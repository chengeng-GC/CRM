package com.cg.crm.workbench.service.impl;

import com.cg.crm.utils.DateTimeUtil;
import com.cg.crm.utils.SqlSessionUtil;
import com.cg.crm.utils.UUIDUtil;
import com.cg.crm.vo.PaginationVO;
import com.cg.crm.workbench.dao.*;
import com.cg.crm.workbench.domain.*;
import com.cg.crm.workbench.service.TranService;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TranServiceImpl implements TranService {
    private TranDao tranDao = SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    private TranHistoryDao tranHistoryDao = SqlSessionUtil.getSqlSession().getMapper(TranHistoryDao.class);
    private CustomerDao customerDao=SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
    private ContactsDao contactsDao = SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);
    private TranRemarkDao tranRemarkDao = SqlSessionUtil.getSqlSession().getMapper(TranRemarkDao.class);
    private ActivityDao activityDao = SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);

    @Override
    public boolean add(Tran t, String customerName) {
        boolean flag=true;
        //（1）根据customerName在客户表进行精确查询
        // 如果有，则取出这个客户的id，封装到t对象中
        // 如果没有，则再客户表新建一条客户信息，然后将新建的客户的id取出，封装到t对象中
        Customer c=customerDao.getByName(customerName);
        if (c==null){
            c=new Customer();
            c.setId(UUIDUtil.getUUID());
            c.setName(customerName);
            c.setCreateBy(t.getCreateBy());
            c.setCreateTime(DateTimeUtil.getSysTime());
            c.setContactSummary(t.getContactSummary());
            c.setNextContactTime(t.getNextContactTime());
            c.setOwner(t.getOwner());
            int count=customerDao.add(c);
            if (count!=1){
                flag=false;
            }
        }
        t.setCustomerId(c.getId());
        //（2）经过以上操作后，t对象中的信息就全了，需要添加交易的操作
        int count1=tranDao.add(t);
        if (count1!=1){
            flag=false;
        }
        //（3）添加交易完毕后，需要创建一条交易历史
        TranHistory tranHistory=new TranHistory();
        tranHistory.setId(UUIDUtil.getUUID());
        tranHistory.setCreateBy(t.getCreateBy());
        tranHistory.setCreateTime(t.getCreateTime());
        tranHistory.setExpectedDate(t.getExpectedDate());
        tranHistory.setMoney(t.getMoney());
        tranHistory.setStage(t.getStage());
        tranHistory.setTranId(t.getId());
        int count2=tranHistoryDao.add(tranHistory);
        if (count2!=1){
            flag=false;
        }


        return flag;
    }

    @Override
    public Tran detail(String id) {
        Tran t=tranDao.detail(id);
        return t;
    }

    @Override
    public List<TranHistory> showHistoryListByTranId(String tranId) {
       List<TranHistory> thList= tranHistoryDao.getListByTranId(tranId);
        return thList;
    }

    @Override
    public boolean changeStage(Tran t) {
        boolean flag=true;
        //改变交易阶段
        int count1=tranDao.changeStage(t);
        if (count1!=1){
            flag=false;
        }

        TranHistory th=new TranHistory();
        th.setId(UUIDUtil.getUUID());
        th.setStage(t.getStage());
        th.setPossibility(t.getPossibility());
        th.setCreateBy(t.getEditBy());
        th.setCreateTime(DateTimeUtil.getSysTime());
        th.setExpectedDate(t.getExpectedDate());
        th.setMoney(t.getMoney());
        th.setTranId(t.getId());
        int count2=tranHistoryDao.add(th);
        if (count2!=1){
            flag=false;
        }
        return flag;
    }

    @Override
    public Map<String, Object> getCharts() {
        int total=tranDao.getTotal();
        List<Map<String,Object>> dataList=tranDao.getCharts();
        Map<String,Object> map=new HashMap<String, Object>();
        map.put("total",total);
        map.put("dataList",dataList);
        return map;
    }

    @Override
    public PaginationVO<Tran> pageList(Map<String, Object> map) {
        System.out.println("进入pageList service层");
        PaginationVO<Tran> vo=new PaginationVO<Tran>();
        List<Tran> tList=tranDao.pageList(map);
        int total=tranDao.countPageList(map);
        vo.setDataList(tList);
        vo.setTotal(total);
        return vo;
    }

    @Override
    public boolean delete(String[] ids) {
        System.out.println("进入delete service层");
        boolean flag=true;
        //删除备注
        int count1=tranRemarkDao.countByTids(ids);
        int count2=tranRemarkDao.deleteByTids(ids);
        if (count1!=count2){
            flag=false;
        }

        //删除阶段历史
        int count3=tranHistoryDao.countByTids(ids);
        int count4=tranHistoryDao.deleteByTids(ids);
        if (count3!=count4){
            flag=false;
        }

        //删除交易
        int count=tranDao.deleteByIds(ids);
        if (count!=ids.length){
            flag=false;
        }
        return flag;
    }

    @Override
    public Map<String,Object> edit(String id) {
        System.out.println("进入edit service层");
        Tran t=tranDao.showCusById(id);
       Contacts con= contactsDao.getById(t.getContactsId());
       Activity a=activityDao.getById(t.getActivityId());
        Map<String,Object> map=new HashMap<String, Object>();
        map.put("t",t);

        map.put("contactsName",((con==null)?null:con.getFullname()));

        map.put("activityName",((a==null)?null:a.getName()));
        return map;
    }

    @Override
    public boolean update(Tran t, String customerName) {
        System.out.println("进入update service层");

        boolean flag=true;
        //（1）根据customerName在客户表进行精确查询
        // 如果没有，则在客户表新建一条客户信息，然后将新建的客户的id取出，封装到t对象中
        Customer c=customerDao.getByName(customerName);
        if (c==null){
            c=new Customer();
            c.setId(UUIDUtil.getUUID());
            c.setName(customerName);
            c.setCreateBy(t.getCreateBy());
            c.setCreateTime(DateTimeUtil.getSysTime());
            c.setContactSummary(t.getContactSummary());
            c.setNextContactTime(t.getNextContactTime());
            c.setOwner(t.getOwner());
            int count=customerDao.add(c);
            if (count!=1){
                flag=false;
            }
        }
        t.setCustomerId(c.getId());
        //更新交易
        int count1=tranDao.update(t);
        if (count1!=1){
            flag=false;
        }
        //（3）更新交易完毕后，需要创建一条交易历史
        TranHistory tranHistory=new TranHistory();
        tranHistory.setId(UUIDUtil.getUUID());
        tranHistory.setCreateBy(t.getEditBy());
        tranHistory.setCreateTime(DateTimeUtil.getSysTime());
        tranHistory.setExpectedDate(t.getExpectedDate());
        tranHistory.setMoney(t.getMoney());
        tranHistory.setStage(t.getStage());
        tranHistory.setTranId(t.getId());
        int count2=tranHistoryDao.add(tranHistory);
        if (count2!=1){
            flag=false;
        }

        return flag;

    }

    @Override
    public List<TranRemark> showRemarkListByTid(String tranId) {
        System.out.println("进入showRemarkListByTid service层");
        List<TranRemark> trList=tranRemarkDao.showOrderByTid(tranId);
        return trList;
    }

    @Override
    public boolean deleteRemark(String id) {
        System.out.println("进入deleteRemark service层");
        boolean flag=true;
        int count=tranRemarkDao.deleteById(id);
        if (count!=1){
            flag=false;
        }

        return flag;
    }

    @Override
    public boolean updateRemark(TranRemark tr) {
        System.out.println("进入updateRemark service层");
        boolean flag=true;
        int count=tranRemarkDao.update(tr);
        if (count!=1){
            flag=false;
        }
        return flag;

    }

    @Override
    public boolean saveRemark(TranRemark tr) {
        System.out.println("进入saveRemark service层");
        boolean flag=true;
        int count=tranRemarkDao.insert(tr);
        if (count!=1){
            flag=false;
        }
        return flag;
    }
}
