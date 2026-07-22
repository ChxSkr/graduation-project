package com.campus.life.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

import java.math.BigDecimal;

/**
 * 课程请求
 */
@Data
public class CourseRequest {

    @NotBlank(message = "课程名称不能为空")
    @Size(max = 100, message = "课程名称过长")
    private String name;

    @Size(max = 50)
    private String teacher;

    @Size(max = 100)
    private String classroom;

    @NotNull(message = "星期不能为空")
    @Min(value = 1, message = "星期取值1-7")
    @Max(value = 7, message = "星期取值1-7")
    private Integer dayOfWeek;

    @NotNull(message = "开始节次不能为空")
    @Min(value = 1, message = "节次取值1-12")
    @Max(value = 12, message = "节次取值1-12")
    private Integer startSection;

    @NotNull(message = "结束节次不能为空")
    @Min(value = 1, message = "节次取值1-12")
    @Max(value = 12, message = "节次取值1-12")
    private Integer endSection;

    @NotNull(message = "起始周不能为空")
    @Min(value = 1)
    @Max(value = 30)
    private Integer weekStart;

    @NotNull(message = "结束周不能为空")
    @Min(value = 1)
    @Max(value = 30)
    private Integer weekEnd;

    private String color = "#1890FF";

    private BigDecimal credit = BigDecimal.ZERO;

    private String remark;
}
