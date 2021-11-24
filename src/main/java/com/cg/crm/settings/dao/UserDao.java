package com.cg.crm.settings.dao;

import com.cg.crm.settings.domain.User;

import java.util.List;
import java.util.Map;

public interface UserDao {
    User login(Map<String, String> map);

    List<User> getUserList();

    int getTotalByCondition(Map<String, Object> map);

    List<User> getUserListByCondition(Map<String, Object> map);

    int save(User u);
}
