package com.cg.crm.workbench.service;

import com.cg.crm.vo.PaginationVO;
import com.cg.crm.workbench.domain.Tran;
import com.cg.crm.workbench.domain.TranHistory;
import com.cg.crm.workbench.domain.TranRemark;

import java.util.List;
import java.util.Map;

public interface TranService {
    boolean add(Tran t, String customerName);

    Tran detail(String id);

    List<TranHistory> showHistoryListByTranId(String tranId);

    boolean changeStage(Tran t);

    Map<String, Object> getCharts();

    PaginationVO<Tran> pageList(Map<String, Object> map);

    boolean delete(String[] ids);


    Map<String,Object> edit(String id);

    boolean update(Tran t, String customerName);

    List<TranRemark> showRemarkListByTid(String tranId);

    boolean deleteRemark(String id);

    boolean updateRemark(TranRemark tr);

    boolean saveRemark(TranRemark tr);
}
