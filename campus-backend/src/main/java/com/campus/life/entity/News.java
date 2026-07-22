package com.campus.life.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 资讯实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("news")
public class News extends BaseEntity {

    /** 标题 */
    private String title;

    /** 摘要 */
    private String summary;

    /** 正文 */
    private String content;

    /** 分类编码 */
    private String categoryCode;

    /** 封面图URL */
    private String coverImage;

    /** 作者 */
    private String author;

    /** 阅读量 */
    private Integer views;

    /** 状态：0-下架 1-上架 */
    private Integer status;

    /** 发布时间 */
    private LocalDateTime publishTime;
}
