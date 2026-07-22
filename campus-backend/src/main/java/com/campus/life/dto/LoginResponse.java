package com.campus.life.dto;

import lombok.Data;

/**
 * 登录响应
 */
@Data
public class LoginResponse {

    private String token;
    private String tokenPrefix;
    private Long expiresIn;
    private UserInfoVO userInfo;

    public static LoginResponse of(String token, String prefix, Long expiresIn, UserInfoVO userInfo) {
        LoginResponse resp = new LoginResponse();
        resp.token = token;
        resp.tokenPrefix = prefix;
        resp.expiresIn = expiresIn;
        resp.userInfo = userInfo;
        return resp;
    }
}
