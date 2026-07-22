package com.campus.life.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.life.dto.*;
import com.campus.life.entity.SysUser;

/**
 * 用户服务接口
 */
public interface SysUserService extends IService<SysUser> {

    /**
     * 登录
     */
    LoginResponse login(LoginRequest request);

    /**
     * 注册
     */
    UserInfoVO register(RegisterRequest request);

    /**
     * 获取当前登录用户信息
     */
    UserInfoVO getCurrentUserInfo();

    /**
     * 根据ID获取用户信息
     */
    SysUser getById(Long userId);

    /**
     * 修改当前用户信息
     */
    UserInfoVO updateCurrentUserInfo(UpdateUserRequest request);

    /**
     * 修改密码
     */
    void changePassword(ChangePasswordRequest request);
}
