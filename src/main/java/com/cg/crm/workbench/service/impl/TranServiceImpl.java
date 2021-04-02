package com.cg.crm.workbench.service.impl;

import com.cg.crm.utils.DateTimeUtil;
import com.cg.crm.utils.SqlSessionUtil;
import com.cg.crm.utils.UUIDUtil;
import com.cg.crm.workbench.dao.CustomerDao;
import com.cg.crm.workbench.dao.TranDao;
import com.cg.crm.workbench.dao.TranHistoryDao;
import com.cg.crm.workbench.domain.Customer;
import com.cg.crm.workbench.domain.Tran;
import com.cg.crm.workbench.domain.TranHistory;
import com.cg.crm.workbench.service.TranService;

import java.util.Date;

public class TranServiceImpl implements TranService {
    private TranDao tranDao = SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    private TranHistoryDao tranHistoryDao = SqlSessionUtil.getSqlSession().getMapper(TranHistoryDao.class);
    private CustomerDao customerDao=SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
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



        return false;
    }
}
