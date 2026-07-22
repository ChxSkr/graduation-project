package com.campus.life.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.life.common.BusinessException;
import com.campus.life.common.ResultCode;
import com.campus.life.dto.*;
import com.campus.life.entity.SysUser;
import com.campus.life.mapper.SysUserMapper;
import com.campus.life.service.SysUserService;
import com.campus.life.utils.JwtUtils;
import com.campus.life.utils.UserContext;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 用户服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SysUserServiceImpl extends ServiceImpl<SysUserMapper, SysUser> implements SysUserService {

    private final JwtUtils jwtUtils;
    private final PasswordEncoder passwordEncoder;

    @Override
    public LoginResponse login(LoginRequest request) {
        SysUser user = findByStudentId(request.getStudentId());
        if (user == null) {
            throw new BusinessException(ResultCode.USER_NOT_EXIST);
        }
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new BusinessException(ResultCode.PASSWORD_ERROR);
        }
        if (user.getStatus() != null && user.getStatus() == 0) {
            throw new BusinessException(ResultCode.USER_DISABLED);
        }

        String token = jwtUtils.generateToken(user.getId(), user.getStudentId(), user.getName());
        log.info("用户登录成功 | userId={} | studentId={}", user.getId(), user.getStudentId());

        return LoginResponse.of(token, jwtUtils.getPrefix(), jwtUtils.getExpiration() / 1000, UserInfoVO.of(user));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public UserInfoVO register(RegisterRequest request) {
        if (findByStudentId(request.getStudentId()) != null) {
            throw new BusinessException(ResultCode.STUDENT_ID_EXISTS);
        }
        SysUser user = new SysUser();
        user.setStudentId(request.getStudentId());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setName(request.getName());
        user.setCollege(request.getCollege());
        user.setMajor(request.getMajor());
        user.setGrade(request.getGrade());
        user.setPhone(request.getPhone());
        user.setEmail(request.getEmail());
        user.setStatus(1);
        save(user);
        log.info("用户注册成功 | userId={} | studentId={}", user.getId(), user.getStudentId());
        return UserInfoVO.of(user);
    }

    @Override
    public UserInfoVO getCurrentUserInfo() {
        Long userId = UserContext.getUserId();
        if (userId == null) {
            throw new BusinessException(ResultCode.UNAUTHORIZED);
        }
        return UserInfoVO.of(getById(userId));
    }

    @Override
    public SysUser getById(Long userId) {
        SysUser user = super.getById(userId);
        if (user == null) {
            throw new BusinessException(ResultCode.USER_NOT_EXIST);
        }
        return user;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public UserInfoVO updateCurrentUserInfo(UpdateUserRequest request) {
        Long userId = UserContext.getUserId();
        SysUser user = getById(userId);
        if (request.getName() != null && !request.getName().trim().isEmpty()) {
            user.setName(request.getName().trim());
        }
        if (request.getCollege() != null && !request.getCollege().trim().isEmpty()) {
            user.setCollege(request.getCollege().trim());
        }
        if (request.getMajor() != null && !request.getMajor().trim().isEmpty()) {
            user.setMajor(request.getMajor().trim());
        }
        if (request.getGrade() != null && !request.getGrade().trim().isEmpty()) {
            user.setGrade(request.getGrade().trim());
        }
        if (request.getAvatar() != null && !request.getAvatar().trim().isEmpty()) {
            user.setAvatar(request.getAvatar().trim());
        }
        if (request.getPhone() != null && !request.getPhone().trim().isEmpty()) {
            user.setPhone(request.getPhone().trim());
        }
        if (request.getEmail() != null && !request.getEmail().trim().isEmpty()) {
            user.setEmail(request.getEmail().trim());
        }
        updateById(user);
        return UserInfoVO.of(user);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void changePassword(ChangePasswordRequest request) {
        Long userId = UserContext.getUserId();
        SysUser user = getById(userId);
        if (!passwordEncoder.matches(request.getOldPassword(), user.getPassword())) {
            throw new BusinessException(ResultCode.PASSWORD_ERROR, "原密码不正确");
        }
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        updateById(user);
    }

    private SysUser findByStudentId(String studentId) {
        return getOne(new LambdaQueryWrapper<SysUser>()
                .eq(SysUser::getStudentId, studentId));
    }
}
