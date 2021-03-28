package com.cg.crm.vo;

import java.util.List;
//将来分页查询，每个模块都有，所以我们选择使用一个通用vo，操作起来比较方便
public class PaginationVO<T> {
    private int total;
    private List<T> dataList;

    public int getTotal() {
        return total;
    }

    public void setTotal(int total) {
        this.total = total;
    }

    public List<T> getDataList() {
        return dataList;
    }

    public void setDataList(List<T> dataList) {
        this.dataList = dataList;
    }
}