package com.cg.crm.workbench.dao;


import com.cg.crm.workbench.domain.ClueActivityRelation;

import java.util.List;

public interface ClueActivityRelationDao {


    int deleteById(String id);

    int add(ClueActivityRelation r);

    List<ClueActivityRelation> getByClueId(String clueId);

    int deleteByClueId(String clueId);
}
