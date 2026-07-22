package com.campus.life.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 资讯分类实体
 */
@Data
@TableName("news_category")
public class NewsCategory implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 分类编码 */
    private String code;

    /** 分类名称 */
    private String name;

    /** 排序 */
    private Integer sort;

    @TableLogic
    @JsonIgnore
    private Integer deleted;

    private LocalDateTime createTime;
}
