package com.cg.crm.settings.service.impl;

import com.cg.crm.settings.dao.DicTypeDao;
import com.cg.crm.settings.dao.DicValueDao;

import com.cg.crm.settings.service.DicService;
import com.cg.crm.utils.SqlSessionUtil;

public class DicServiceImpl implements DicService {
    private DicTypeDao dicTypeDao= SqlSessionUtil.getSqlSession().getMapper(DicTypeDao.class);
    private DicValueDao dicValueDap= SqlSessionUtil.getSqlSession().getMapper(DicValueDao.class);

}
