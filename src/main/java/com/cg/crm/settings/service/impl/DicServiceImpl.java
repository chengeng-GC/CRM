package com.cg.crm.settings.service.impl;

import com.cg.crm.settings.dao.DicTypeDao;
import com.cg.crm.settings.dao.DicValueDao;

import com.cg.crm.settings.domain.DicType;
import com.cg.crm.settings.domain.DicValue;
import com.cg.crm.settings.service.DicService;
import com.cg.crm.utils.SqlSessionUtil;

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
}
