package com.campus.life.utils;

/**
 * 用户上下文（基于 ThreadLocal）
 * 用于在拦截器中存储当前登录用户信息，供后续业务使用
 */
public class UserContext {

    private static final ThreadLocal<Long> USER_ID = new ThreadLocal<>();
    private static final ThreadLocal<String> STUDENT_ID = new ThreadLocal<>();
    private static final ThreadLocal<String> NAME = new ThreadLocal<>();

    public static void setUserId(Long userId) {
        USER_ID.set(userId);
    }

    public static Long getUserId() {
        return USER_ID.get();
    }

    public static void setStudentId(String studentId) {
        STUDENT_ID.set(studentId);
    }

    public static String getStudentId() {
        return STUDENT_ID.get();
    }

    public static void setName(String name) {
        NAME.set(name);
    }

    public static String getName() {
        return NAME.get();
    }

    public static void clear() {
        USER_ID.remove();
        STUDENT_ID.remove();
        NAME.remove();
    }
}
