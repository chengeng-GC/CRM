package com.cg.crm.workbench.service.impl;

import com.cg.crm.utils.SqlSessionUtil;
import com.cg.crm.workbench.dao.TranDao;
import com.cg.crm.workbench.dao.TranHistoryDao;
import com.cg.crm.workbench.domain.Tran;
import com.cg.crm.workbench.service.TranService;

public class TranServiceImpl implements TranService {
    private TranDao tranDao = SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    private TranHistoryDao tranHistoryDao = SqlSessionUtil.getSqlSession().getMapper(TranHistoryDao.class);

}
