package com.campus.life.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

/**
 * 充值请求
 */
@Data
public class RechargeRequest {

    @NotNull(message = "充值金额不能为空")
    @DecimalMin(value = "0.01", message = "充值金额必须大于0")
    @Max(value = 10000, message = "单次充值不能超过10000元")
    private BigDecimal amount;

    /** 充值方式：微信/支付宝（仅记录，不参与业务逻辑） */
    private String channel = "微信";

    private String description;
}
