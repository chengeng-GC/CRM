package com.cg.crm.settings.dao;

import com.cg.crm.settings.domain.DicValue;

import java.util.List;
import java.util.Map;

public interface DicValueDao {
    List<DicValue> getByTypeCode(String code);

    int getTotalbyTypeCode(Map<String,Object> map);

    List<DicValue> getByPage(Map<String, Object> map);
}
