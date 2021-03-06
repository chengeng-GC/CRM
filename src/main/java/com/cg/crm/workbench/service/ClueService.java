package com.cg.crm.workbench.service;

import com.cg.crm.vo.PaginationVO;
import com.cg.crm.workbench.domain.Clue;
import com.cg.crm.workbench.domain.ClueRemark;
import com.cg.crm.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface ClueService {
    boolean saveClue(Clue c);

    PaginationVO<Clue> pageList(Map<String, Object> map);

    Clue detail(String id);

    boolean unbund(String id);

    boolean bund(Map<String, Object> map);


    boolean convert(String clueId, Tran t, String createBy);

    boolean delete(String[] ids);

    Clue getById(String id);

    boolean update(Clue c);

    List<ClueRemark> showRemarkListByCid(String clueId);

    boolean saveRemark(ClueRemark cr);

    boolean deleteRemark(String id);

    boolean updateRemark(ClueRemark cr);
}
