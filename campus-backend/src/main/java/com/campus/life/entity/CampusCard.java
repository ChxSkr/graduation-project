package com.campus.life.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;

/**
 * 校园卡实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("campus_card")
public class CampusCard extends BaseEntity {

    /** 用户ID */
    private Long userId;

    /** 卡号 */
    private String cardNo;

    /** 余额 */
    private BigDecimal balance;

    /** 持卡人姓名 */
    private String userName;

    /** 状态：normal/frozen/lost */
    private String status;
}
