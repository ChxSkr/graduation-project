package com.campus.life.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 失物招领实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("lost_found")
public class LostFound extends BaseEntity {

    /** 发布人ID */
    private Long userId;

    /** 类型：lost/found */
    private String type;

    /** 标题 */
    private String title;

    /** 描述 */
    private String description;

    /** 地点 */
    private String location;

    /** 联系方式 */
    private String contact;

    /** 分类 */
    private String category;

    /** 图片URL（逗号分隔） */
    private String images;

    /** 状态：active/completed */
    private String status;

    /** 事件发生时间 */
    private LocalDateTime eventTime;

    /** 发布时间 */
    private LocalDateTime publishTime;
}
