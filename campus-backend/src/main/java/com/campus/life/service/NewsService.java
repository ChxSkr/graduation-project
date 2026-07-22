package com.campus.life.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.life.entity.News;
import com.campus.life.entity.NewsCategory;

import java.util.List;

/**
 * 资讯服务接口
 */
public interface NewsService extends IService<News> {

    /**
     * 分页查询资讯
     * @param current 当前页（从1开始）
     * @param size 每页数量
     * @param categoryCode 分类编码（null 或 "all" 表示全部）
     * @param keyword 搜索关键词（标题/摘要）
     */
    Page<News> pageNews(Long current, Long size, String categoryCode, String keyword);

    /**
     * 获取资讯详情（同时增加阅读量）
     */
    News getNewsDetail(Long id);

    /**
     * 获取所有资讯分类
     */
    List<NewsCategory> listCategories();

    /**
     * 获取最新 N 条资讯（用于首页轮播 / 公告）
     */
    List<News> listLatest(String categoryCode, Integer limit);
}
