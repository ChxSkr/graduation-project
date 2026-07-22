package com.campus.life.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 用户实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("sys_user")
public class SysUser extends BaseEntity {

    /** 学号 */
    private String studentId;

    /** 密码（BCrypt 加密） */
    @JsonIgnore
    private String password;

    /** 姓名 */
    private String name;

    /** 学院 */
    private String college;

    /** 专业 */
    private String major;

    /** 年级 */
    private String grade;

    /** 头像URL */
    private String avatar;

    /** 手机号 */
    private String phone;

    /** 邮箱 */
    private String email;

    /** 账号状态：0-禁用 1-正常 */
    private Integer status;
}
