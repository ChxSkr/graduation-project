package com.campus.life.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 校园卡消费记录实体
 */
@Data
@TableName("card_record")
public class CardRecord implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long cardId;

    private Long userId;

    /** 金额（正为充值，负为消费） */
    private BigDecimal amount;

    /** 类型：recharge/consume */
    private String type;

    private String location;

    private String description;

    /** 记录时间 */
    private LocalDateTime recordTime;

    @TableLogic
    @JsonIgnore
    private Integer deleted;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}
