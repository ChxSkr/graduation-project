package com.campus.life.dto;

import lombok.Data;

/**
 * 修改用户信息请求
 */
@Data
public class UpdateUserRequest {

    private String name;
    private String college;
    private String major;
    private String grade;
    private String avatar;
    private String phone;
    private String email;
}
