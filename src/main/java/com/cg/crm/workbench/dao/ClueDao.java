package com.cg.crm.workbench.dao;


import com.cg.crm.workbench.domain.Clue;

import java.util.List;
import java.util.Map;

public interface ClueDao {

    int save(Clue c);

    List<Clue> getListByCondition(Map<String, Object> map);

    int getCountByCondition(Map<String, Object> map);

    Clue getById(String id);

    Clue showById(String id);

    int deleteById(String clueId);

    int deleteByIds(String[] ids);
}
