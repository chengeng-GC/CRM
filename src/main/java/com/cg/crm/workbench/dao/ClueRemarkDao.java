package com.cg.crm.workbench.dao;

import com.cg.crm.workbench.domain.ClueRemark;

import java.util.List;

public interface ClueRemarkDao {

    List<ClueRemark> getByClueId(String clueId);


    int deleteByClueId(String clueId);
}
