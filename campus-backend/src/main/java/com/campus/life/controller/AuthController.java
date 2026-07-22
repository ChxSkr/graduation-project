package com.campus.life.controller;

import com.campus.life.common.Result;
import com.campus.life.dto.LoginRequest;
import com.campus.life.dto.LoginResponse;
import com.campus.life.dto.RegisterRequest;
import com.campus.life.dto.UserInfoVO;
import com.campus.life.service.SysUserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 认证 Controller（登录 / 注册）
 * 路径前缀：/auth —— 已在拦截器中放行
 */
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final SysUserService userService;

    /**
     * 登录
     * POST /api/auth/login
     */
    @PostMapping("/login")
    public Result<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        return Result.success(userService.login(request));
    }

    /**
     * 注册
     * POST /api/auth/register
     */
    @PostMapping("/register")
    public Result<UserInfoVO> register(@Valid @RequestBody RegisterRequest request) {
        return Result.success(userService.register(request), "注册成功");
    }
}
