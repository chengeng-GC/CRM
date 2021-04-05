package com.cg.crm.workbench.service;

import com.cg.crm.workbench.domain.Tran;
import com.cg.crm.workbench.domain.TranHistory;

import java.util.List;

public interface TranService {
    boolean add(Tran t, String customerName);

    Tran detail(String id);

    List<TranHistory> showHistoryListByTranId(String tranId);

    boolean changeStage(Tran t);
}
