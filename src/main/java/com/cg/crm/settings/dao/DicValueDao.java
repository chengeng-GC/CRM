package com.cg.crm.settings.dao;

import com.cg.crm.settings.domain.DicValue;

import java.util.List;

public interface DicValueDao {
    List<DicValue> getByTypeCode(String code);
}
