package com.campus.life.common;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 系统状态码
 */
@Getter
@AllArgsConstructor
public enum ResultCode {

    SUCCESS(200, "操作成功"),
    CREATED(201, "创建成功"),
    NO_CONTENT(204, "无内容"),

    BAD_REQUEST(400, "请求参数错误"),
    UNAUTHORIZED(401, "未登录或登录已过期"),
    FORBIDDEN(403, "无权限访问"),
    NOT_FOUND(404, "资源不存在"),
    METHOD_NOT_ALLOWED(405, "请求方法不允许"),

    BUSINESS_ERROR(500, "业务处理失败"),
    SERVER_ERROR(500, "服务器内部错误"),

    // 业务相关错误码（1xxx）
    USER_NOT_EXIST(1001, "用户不存在"),
    PASSWORD_ERROR(1002, "密码错误"),
    USER_DISABLED(1003, "账号已被禁用"),
    STUDENT_ID_EXISTS(1004, "学号已存在"),
    CARD_NOT_EXIST(1005, "校园卡不存在"),
    CARD_LOST(1006, "校园卡已挂失"),
    CARD_FROZEN(1007, "校园卡已冻结"),
    BALANCE_NOT_ENOUGH(1008, "余额不足"),
    COURSE_NOT_EXIST(1009, "课程不存在"),
    NEWS_NOT_EXIST(1010, "资讯不存在"),
    LOST_FOUND_NOT_EXIST(1011, "失物招领信息不存在");

    private final Integer code;
    private final String message;
}
