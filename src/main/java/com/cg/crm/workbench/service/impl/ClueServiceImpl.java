package com.cg.crm.workbench.service.impl;

import com.cg.crm.utils.SqlSessionUtil;
import com.cg.crm.utils.UUIDUtil;
import com.cg.crm.vo.PaginationVO;
import com.cg.crm.workbench.dao.ClueActivityRelationDao;
import com.cg.crm.workbench.dao.ClueDao;
import com.cg.crm.workbench.domain.Clue;
import com.cg.crm.workbench.domain.ClueActivityRelation;
import com.cg.crm.workbench.service.ClueService;

import java.util.List;
import java.util.Map;

public class ClueServiceImpl implements ClueService {
private ClueDao clueDao= SqlSessionUtil.getSqlSession().getMapper(ClueDao.class);
private ClueActivityRelationDao clueActivityRelationDao= SqlSessionUtil.getSqlSession().getMapper(ClueActivityRelationDao.class);

    @Override
    public boolean saveClue(Clue c) {
        boolean flag=true;
        int count=clueDao.save(c);
        if (count!=1){
            flag=false;
        }
        return flag;
    }

    @Override
    public PaginationVO<Clue> pageList(Map<String, Object> map) {
        PaginationVO vo=new PaginationVO();
        //取得查询的总条数
        int total=clueDao.getCountByCondition(map);
        //取得查询的结果List
        List<Clue> cList=clueDao.getListByCondition(map);

        vo.setTotal(total);
        vo.setDataList(cList);

        return vo;
    }

    @Override
    public Clue detail(String id) {
       Clue c= clueDao.getById(id);
        return c;
    }

    @Override
    public boolean unbund(String id) {
        boolean flag=true;
        int count=clueActivityRelationDao.deleteById(id);
        if (count!=1){
            flag=false;
        }
        return flag;
    }

    @Override
    public boolean bund(Map<String, Object> map) {
        boolean flag=true;
        String[] aids= (String[]) map.get("aids");
        String cid= (String) map.get("cid");
        ClueActivityRelation r=new ClueActivityRelation();
        r.setClueId(cid);
        for (String aid:aids) {
            r.setActivityId(aid);
            r.setId(UUIDUtil.getUUID());
            int count=clueActivityRelationDao.add(r);
            if (count!=1){
               flag=false;
            }
        }

        return flag;
    }
}
