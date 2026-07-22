package com.campus.life.common;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.Data;

import java.io.Serializable;
import java.util.Collections;
import java.util.List;

/**
 * 分页响应结果
 */
@Data
public class PageResult<T> implements Serializable {

    private List<T> records;
    private Long total;
    private Long current;
    private Long size;
    private Long pages;

    public PageResult() {
        this.records = Collections.emptyList();
    }

    public PageResult(Page<T> page) {
        this.records = page.getRecords();
        this.total = page.getTotal();
        this.current = page.getCurrent();
        this.size = page.getSize();
        this.pages = page.getPages();
    }

    public static <T> PageResult<T> of(Page<T> page) {
        return new PageResult<>(page);
    }
}
