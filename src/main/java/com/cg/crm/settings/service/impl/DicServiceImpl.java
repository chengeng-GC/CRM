package com.cg.crm.settings.service.impl;

import com.cg.crm.settings.dao.DicTypeDao;
import com.cg.crm.settings.dao.DicValueDao;

import com.cg.crm.settings.domain.DicType;
import com.cg.crm.settings.domain.DicValue;
import com.cg.crm.settings.domain.User;
import com.cg.crm.settings.service.DicService;
import com.cg.crm.utils.SqlSessionUtil;
import com.cg.crm.vo.PaginationVO;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DicServiceImpl implements DicService {
    private DicTypeDao dicTypeDao= SqlSessionUtil.getSqlSession().getMapper(DicTypeDao.class);
    private DicValueDao dicValueDao= SqlSessionUtil.getSqlSession().getMapper(DicValueDao.class);

    @Override
    public Map<String, List<DicValue>> getAll() {
        //将字典类型列表取出
       List<DicType> dtList= dicTypeDao.getAll();
       Map<String,List<DicValue>> map=new HashMap<String, List<DicValue>>();
       for (DicType dicType:dtList) {
           String typeCode=dicType.getCode();
           List<DicValue> dvList=dicValueDao.getByTypeCode(typeCode);
           map.put(typeCode,dvList);
       }
        return map;
    }

    @Override
    public PaginationVO<DicType> pageListType(Map<String, Object> map) {
        //取得total
        int total=dicTypeDao.getTotal();
        //取得dataList
        List<DicType> alist=dicTypeDao.getByPage(map);
        //将total和dataList封装到vo中
        PaginationVO<DicType> vo=new PaginationVO<DicType>();
        vo.setTotal(total);
        vo.setDataList(alist);
        //将vo返回
        return vo;

    }

    @Override
    public PaginationVO<DicValue> pageListValue(Map<String, Object> map) {
        //取得total
        int total=dicValueDao.getTotalbyTypeCode(map);
        //取得dataList
        List<DicValue> alist=dicValueDao.getByPage(map);
        //将total和dataList封装到vo中
        PaginationVO<DicValue> vo=new PaginationVO<DicValue>();
        vo.setTotal(total);
        vo.setDataList(alist);
        //将vo返回
        return vo;

    }
}
