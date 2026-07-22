package com.campus.life.controller;

import com.campus.life.common.PageResult;
import com.campus.life.common.Result;
import com.campus.life.entity.News;
import com.campus.life.entity.NewsCategory;
import com.campus.life.service.NewsService;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 资讯 Controller
 * 路径前缀：/news，整个模块都是公开接口（无需登录）
 * 已在 WebMvcConfig 中放行 /public/**，因此实际路径为 /public/news/**
 * 同时也保留 /news/**，方便后续加上鉴权（如管理员发布）
 */
@RestController
@RequestMapping("/news")
@RequiredArgsConstructor
public class NewsController {

    private final NewsService newsService;

    /**
     * 分页查询资讯
     * GET /api/news/page?current=1&size=10&categoryCode=all&keyword=
     */
    @GetMapping("/page")
    public Result<PageResult<News>> page(@RequestParam(required = false, defaultValue = "1") Long current,
                                         @RequestParam(required = false, defaultValue = "10") Long size,
                                         @RequestParam(required = false, defaultValue = "all") String categoryCode,
                                         @RequestParam(required = false) String keyword) {
        Page<News> page = newsService.pageNews(current, size, categoryCode, keyword);
        return Result.success(PageResult.of(page));
    }

    /**
     * 获取所有分类
     * GET /api/news/categories
     */
    @GetMapping("/categories")
    public Result<List<NewsCategory>> categories() {
        return Result.success(newsService.listCategories());
    }

    /**
     * 获取资讯详情
     * GET /api/news/{id}
     */
    @GetMapping("/{id}")
    public Result<News> detail(@PathVariable Long id) {
        return Result.success(newsService.getNewsDetail(id));
    }

    /**
     * 获取最新 N 条资讯
     * GET /api/news/latest?categoryCode=campus&limit=5
     */
    @GetMapping("/latest")
    public Result<List<News>> latest(@RequestParam(required = false) String categoryCode,
                                     @RequestParam(required = false, defaultValue = "5") Integer limit) {
        return Result.success(newsService.listLatest(categoryCode, limit));
    }
}
