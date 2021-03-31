package com.cg.crm.workbench.service;

import com.cg.crm.vo.PaginationVO;
import com.cg.crm.workbench.domain.Clue;

import java.util.Map;

public interface ClueService {
    boolean saveClue(Clue c);

    PaginationVO<Clue> pageList(Map<String, Object> map);

    Clue detail(String id);

    boolean unbund(String id);

    boolean bund(Map<String, Object> map);
}
