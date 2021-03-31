package com.cg.crm.workbench.dao;


import com.cg.crm.workbench.domain.ClueActivityRelation;

public interface ClueActivityRelationDao {


    int deleteById(String id);

    int add(ClueActivityRelation r);
}
