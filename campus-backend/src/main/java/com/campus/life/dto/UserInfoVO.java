package com.campus.life.dto;

import com.campus.life.entity.SysUser;
import lombok.Data;

/**
 * 用户信息 VO（对外响应，不含密码）
 */
@Data
public class UserInfoVO {

    private Long id;
    private String studentId;
    private String name;
    private String college;
    private String major;
    private String grade;
    private String avatar;
    private String phone;
    private String email;

    public static UserInfoVO of(SysUser user) {
        if (user == null) {
            return null;
        }
        UserInfoVO vo = new UserInfoVO();
        vo.id = user.getId();
        vo.studentId = user.getStudentId();
        vo.name = user.getName();
        vo.college = user.getCollege();
        vo.major = user.getMajor();
        vo.grade = user.getGrade();
        vo.avatar = user.getAvatar();
        vo.phone = user.getPhone();
        vo.email = user.getEmail();
        return vo;
    }
}
