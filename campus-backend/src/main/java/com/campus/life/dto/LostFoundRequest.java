package com.campus.life.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 失物招领发布请求
 */
@Data
public class LostFoundRequest {

    @NotBlank(message = "类型不能为空")
    private String type; // lost / found

    @NotBlank(message = "标题不能为空")
    @Size(max = 100)
    private String title;

    @NotBlank(message = "描述不能为空")
    private String description;

    @NotBlank(message = "地点不能为空")
    private String location;

    @NotBlank(message = "联系方式不能为空")
    private String contact;

    private String category;

    /** 图片URL列表（前端传数组，后端拼接成逗号分隔字符串） */
    private List<String> images;

    /** 事件发生时间（前端传 ISO 字符串） */
    private LocalDateTime eventTime;
}
