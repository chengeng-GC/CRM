package com.cg.crm.workbench.dao;

import com.cg.crm.workbench.domain.ClueRemark;

import java.util.List;

public interface ClueRemarkDao {

    List<ClueRemark> getByClueId(String clueId);

    int deleteByClueId(String clueId);

    int getCountByCids(String[] ids);

    int deleteByCids(String[] ids);

    int insert(ClueRemark cr);

    List<ClueRemark> showByClueId(String clueId);

    int deleteById(String id);

    int update(ClueRemark cr);
}
