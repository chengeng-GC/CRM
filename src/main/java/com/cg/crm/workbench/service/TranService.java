package com.cg.crm.workbench.service;

import com.cg.crm.workbench.domain.Tran;

public interface TranService {
    boolean add(Tran t, String customerName);
}
