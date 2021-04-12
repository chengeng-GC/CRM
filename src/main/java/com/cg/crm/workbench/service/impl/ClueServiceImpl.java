package com.cg.crm.workbench.service.impl;

import com.cg.crm.utils.DateTimeUtil;
import com.cg.crm.utils.SqlSessionUtil;
import com.cg.crm.utils.UUIDUtil;
import com.cg.crm.vo.PaginationVO;
import com.cg.crm.workbench.dao.*;
import com.cg.crm.workbench.domain.*;
import com.cg.crm.workbench.service.ClueService;

import java.util.List;
import java.util.Map;

public class ClueServiceImpl implements ClueService {
    //线索相关
    private ClueDao clueDao = SqlSessionUtil.getSqlSession().getMapper(ClueDao.class);
    private ClueActivityRelationDao clueActivityRelationDao = SqlSessionUtil.getSqlSession().getMapper(ClueActivityRelationDao.class);
    private ClueRemarkDao clueRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ClueRemarkDao.class);
    //客户相关
    private CustomerDao customerDao = SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
    private CustomerRemarkDao customerRemarkDao = SqlSessionUtil.getSqlSession().getMapper(CustomerRemarkDao.class);
    //联系人相关
    private ContactsDao contactsDao = SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);
    private ContactsRemarkDao contactsRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ContactsRemarkDao.class);
    private ContactsActivityRelationDao contactsActivityRelationDao = SqlSessionUtil.getSqlSession().getMapper(ContactsActivityRelationDao.class);
    //交易相关
    private TranDao tranDao = SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    private TranHistoryDao tranHistoryDao = SqlSessionUtil.getSqlSession().getMapper(TranHistoryDao.class);


    @Override
    public boolean saveClue(Clue c) {
        boolean flag = true;
        int count = clueDao.save(c);
        if (count != 1) {
            flag = false;
        }
        return flag;
    }

    @Override
    public PaginationVO<Clue> pageList(Map<String, Object> map) {
        PaginationVO vo = new PaginationVO();
        //取得查询的总条数
        int total = clueDao.getCountByCondition(map);
        //取得查询的结果List
        List<Clue> cList = clueDao.getListByCondition(map);

        vo.setTotal(total);
        vo.setDataList(cList);

        return vo;
    }

    @Override
    public Clue detail(String id) {
        Clue c = clueDao.showById(id);
        return c;
    }

    @Override
    public boolean unbund(String id) {
        boolean flag = true;
        int count = clueActivityRelationDao.deleteById(id);
        if (count != 1) {
            flag = false;
        }
        return flag;
    }

    @Override
    public boolean bund(Map<String, Object> map) {
        boolean flag = true;
        String[] aids = (String[]) map.get("aids");
        String cid = (String) map.get("cid");
        ClueActivityRelation r = new ClueActivityRelation();
        r.setClueId(cid);
        for (String aid : aids) {
            r.setActivityId(aid);
            r.setId(UUIDUtil.getUUID());
            int count = clueActivityRelationDao.add(r);
            if (count != 1) {
                flag = false;
            }
        }

        return flag;
    }

    @Override
    public boolean convert(String clueId, Tran t, String createBy) {
        boolean flag = true;
        String createTime= DateTimeUtil.getSysTime();
//    （1）获取到线索id，通过线索id获取线索对象
         Clue c= clueDao.getById(clueId);

//    （2）通过线索对象提取客户信息，当该客户不存在的时候，新建客户（根据公司名称精确匹配，判断该客户是否存在
        String company=c.getCompany();
        Customer customer=customerDao.getByName(company);
        if(customer==null){
            customer =new Customer();
            customer.setId(UUIDUtil.getUUID());
            customer.setAddress(c.getAddress());
            customer.setWebsite(c.getWebsite());
            customer.setPhone(c.getPhone());
            customer.setOwner(c.getOwner());
            customer.setNextContactTime(c.getNextContactTime());
            customer.setName(company);
            customer.setDescription(c.getDescription());
            customer.setCreateTime(createTime);
            customer.setCreateBy(createBy);
            customer.setContactSummary(c.getContactSummary());
            //添加客户
            int count1=customerDao.add(customer);
            if (count1!=1){
             flag=false;
            }
        }
        //经过第第二步处理过后，客户的信息我们已经拥有了
        //若要用到客户id，直接customer.getId就行，因为存进去什么就是什么
//    （3）通过线索对象提取联系人信息，保存联系人。
        Contacts contacts=new Contacts();
        contacts.setId(UUIDUtil.getUUID());
        contacts.setSource(c.getSource());
        contacts.setOwner(c.getOwner());
        contacts.setNextContactTime(c.getNextContactTime());
        contacts.setMphone(c.getMphone());
        contacts.setJob(c.getJob());
        contacts.setFullname(c.getFullname());
        contacts.setEmail(c.getEmail());
        contacts.setDescription(c.getDescription());
        contacts.setCustomerId(customer.getId());
        contacts.setCreateTime(createTime);
        contacts.setCreateBy(createBy);
        contacts.setContactSummary(c.getContactSummary());
        contacts.setAppellation(c.getAppellation());
        contacts.setAddress(c.getAddress());
        int count2 =contactsDao.add(contacts);
        if (count2!=1){
            flag=false;
        }
        //同上，联系人信息可用

//    （4）线索备注转换到客户备注以及联系人备注
        //查询出与该线索关联的备注信息列表
        List<ClueRemark> clueRemarkList= clueRemarkDao.getByClueId(clueId);
        //遍历列表，取出单个信息
        for (ClueRemark clueRemark:clueRemarkList){
            //取出备注信息（转换到客户备注以及联系人备注的就是这个信息，别的都有现成的）
            String noteContent=clueRemark.getNoteContent();
            //创建客户备注对象，添加客户备注
            CustomerRemark customerRemark=new CustomerRemark();
            customerRemark.setId(UUIDUtil.getUUID());
            customerRemark.setCreateBy(createBy);
            customerRemark.setCreateTime(createTime);
            customerRemark.setCustomerId(customer.getId());
            customerRemark.setEditFlag("0");
            customerRemark.setNoteContent(noteContent);
            int count3=customerRemarkDao.add(customerRemark);
            if (count3!=1){
                flag=false;
            }
            //创建联系人备注对象，添加联系人
            ContactsRemark contactsRemark=new ContactsRemark();
            contactsRemark.setId(UUIDUtil.getUUID());
            contactsRemark.setCreateBy(createBy);
            contactsRemark.setCreateTime(createTime);
            contactsRemark.setContactsId(contacts.getId());
            contactsRemark.setEditFlag("0");
            contactsRemark.setNoteContent(noteContent);
            int count4=contactsRemarkDao.add(contactsRemark);
            if (count4!=1){
                flag=false;
            }
        }

//    （5）“线索和市场活动”的关系转换到“联系人和市场活动”的关系。
        //查询出与该线索关联的关系表
        List<ClueActivityRelation> clueActivityRelationList=clueActivityRelationDao.getByClueId(clueId);
        for(ClueActivityRelation clueActivityRelation:clueActivityRelationList){
            //遍历取出关联的市场活动id
            String activityId=clueActivityRelation.getActivityId();
            //创建联系人市场活动关系对象，添加联系人市场活动关系
            ContactsActivityRelation contactsActivityRelation=new ContactsActivityRelation();
            contactsActivityRelation.setId(UUIDUtil.getUUID());
            contactsActivityRelation.setContactsId(contacts.getId());
            contactsActivityRelation.setActivityId(activityId);
            int count5=contactsActivityRelationDao.add(contactsActivityRelation);
            if (count5!=1){
                flag=false;
            }

        }

//    （6）如果有创建交易需求，创建一条交易。
        if (t!=null){
            t.setSource(c.getSource());
            t.setOwner(c.getOwner());
            t.setNextContactTime(c.getNextContactTime());
            t.setDescription(c.getDescription());
            t.setCustomerId(customer.getId());
            t.setContactSummary(c.getContactSummary());
            t.setContactsId(contacts.getId());
            //添加交易
            int count6=tranDao.add(t);
            if (count6!=1){
                flag=false;
            }

            //    （7）如果创建了交易，则创建一条该交易下的交易历史
            TranHistory tranHistory=new TranHistory();
            tranHistory.setId(UUIDUtil.getUUID());
            tranHistory.setCreateBy(createBy);
            tranHistory.setCreateTime(createTime);
            tranHistory.setExpectedDate(t.getExpectedDate());
            tranHistory.setMoney(t.getMoney());
            tranHistory.setStage(t.getStage());
            tranHistory.setTranId(t.getId());
            int count7=tranHistoryDao.add(tranHistory);
            if (count7!=1){
                flag=false;
            }

        }




//    （8）删除线索备注

            int count8=clueRemarkDao.deleteByClueId(clueId);
            if (count8!=clueRemarkList.size()){
                flag=false;
            }


//    （9)删除线索和市场活动的关系。
        int count9=clueActivityRelationDao.deleteByClueId(clueId);
        if (count9!=clueActivityRelationList.size()){
            flag=false;
        }
//    （10）删除线索。
        int count10=clueDao.deleteById(clueId);
        if (count10!=1){
            flag=false;
        }


        return flag;
    }

    @Override
    public boolean delete(String[] ids) {

        boolean flag=true;
        //查询出需要删除的备注的数量
        int count1 = clueRemarkDao.getCountByCids(ids);
        //删除备注，返回受到影响的条数（实际删除的数量）
        int count2=clueRemarkDao.deleteByCids(ids);
        if (count1!=count2){
            flag=false;
        }
        //删除市场活动
        int count3=clueDao.deleteByIds(ids);
        if (count3!=ids.length){
            flag=false;
        }
        return flag;
    }


}
