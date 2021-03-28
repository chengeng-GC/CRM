package com.cg.crm.workbench.service.impl;

import com.cg.crm.utils.SqlSessionUtil;
import com.cg.crm.workbench.dao.ClueDao;
import com.cg.crm.workbench.service.ClueService;

public class ClueServiceImpl implements ClueService {
private ClueDao clueDao= SqlSessionUtil.getSqlSession().getMapper(ClueDao.class);
}
