package com.campus.life.dto;

import lombok.Data;

import java.math.BigDecimal;

/**
 * 月度统计
 */
@Data
public class MonthlySummaryVO {

    private String month;
    private BigDecimal totalRecharge;
    private BigDecimal totalConsume;
}
