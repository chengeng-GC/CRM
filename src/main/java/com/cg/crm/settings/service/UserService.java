package com.cg.crm.settings.service;

import com.cg.crm.exception.LoginException;
import com.cg.crm.settings.domain.User;
import com.cg.crm.vo.PaginationVO;

import java.util.List;
import java.util.Map;

public interface UserService {
    User login(String loginAct, String loginPwd, String ip) throws LoginException;

    List<User> getUserList();

    PaginationVO<User> pageList(Map<String, Object> map);

    boolean save(User u);

    boolean delete(String[] ids);
}
