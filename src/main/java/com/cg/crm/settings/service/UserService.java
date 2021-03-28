package com.cg.crm.settings.service;

import com.cg.crm.exception.LoginException;
import com.cg.crm.settings.domain.User;

import java.util.List;

public interface UserService {
    User login(String loginAct, String loginPwd, String ip) throws LoginException;

    List<User> getUserList();
}
