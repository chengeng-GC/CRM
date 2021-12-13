package com.cg.crm.settings.dao;

import com.cg.crm.settings.domain.DicType;

import java.util.List;
import java.util.Map;

public interface DicTypeDao {
    List<DicType> getAll();

    int getTotal();

    List<DicType> getByPage(Map<String, Object> map);
}
