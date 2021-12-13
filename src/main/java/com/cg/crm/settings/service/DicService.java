package com.cg.crm.settings.service;

import com.cg.crm.settings.domain.DicType;
import com.cg.crm.settings.domain.DicValue;
import com.cg.crm.vo.PaginationVO;

import java.util.List;
import java.util.Map;

public interface DicService {
    Map<String, List<DicValue>> getAll();

    PaginationVO<DicType> pageListType(Map<String, Object> map);

    PaginationVO<DicValue> pageListValue(Map<String, Object> map);
}
