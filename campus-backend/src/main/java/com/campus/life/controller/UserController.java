package com.campus.life.controller;

import com.campus.life.common.Result;
import com.campus.life.dto.ChangePasswordRequest;
import com.campus.life.dto.UpdateUserRequest;
import com.campus.life.dto.UserInfoVO;
import com.campus.life.service.SysUserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 用户 Controller
 * 路径前缀：/user
 */
@RestController
@RequestMapping("/user")
@RequiredArgsConstructor
public class UserController {

    private final SysUserService userService;

    /**
     * 获取当前登录用户信息
     * GET /api/user/info
     */
    @GetMapping("/info")
    public Result<UserInfoVO> getCurrentUserInfo() {
        return Result.success(userService.getCurrentUserInfo());
    }

    /**
     * 修改当前用户信息
     * PUT /api/user/info
     */
    @PutMapping("/info")
    public Result<UserInfoVO> updateUserInfo(@Valid @RequestBody UpdateUserRequest request) {
        return Result.success(userService.updateCurrentUserInfo(request), "修改成功");
    }

    /**
     * 修改密码
     * PUT /api/user/password
     */
    @PutMapping("/password")
    public Result<Void> changePassword(@Valid @RequestBody ChangePasswordRequest request) {
        userService.changePassword(request);
        return Result.success(null, "密码修改成功");
    }
}
