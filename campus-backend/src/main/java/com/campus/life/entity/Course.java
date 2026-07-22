package com.campus.life.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;

/**
 * 课程实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("course")
public class Course extends BaseEntity {

    /** 用户ID */
    private Long userId;

    /** 课程名称 */
    private String name;

    /** 授课教师 */
    private String teacher;

    /** 教室 */
    private String classroom;

    /** 星期几：1-7 */
    private Integer dayOfWeek;

    /** 开始节次：1-12 */
    private Integer startSection;

    /** 结束节次：1-12 */
    private Integer endSection;

    /** 起始周 */
    private Integer weekStart;

    /** 结束周 */
    private Integer weekEnd;

    /** 课程卡片颜色 */
    private String color;

    /** 学分 */
    private BigDecimal credit;

    /** 备注 */
    private String remark;
}
