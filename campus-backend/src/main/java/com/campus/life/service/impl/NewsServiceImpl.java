package com.campus.life.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.life.common.BusinessException;
import com.campus.life.common.ResultCode;
import com.campus.life.entity.News;
import com.campus.life.entity.NewsCategory;
import com.campus.life.mapper.NewsCategoryMapper;
import com.campus.life.mapper.NewsMapper;
import com.campus.life.service.NewsService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;

/**
 * 资讯服务实现
 */
@Service
@RequiredArgsConstructor
public class NewsServiceImpl extends ServiceImpl<NewsMapper, News> implements NewsService {

    private final NewsCategoryMapper newsCategoryMapper;

    @Override
    public Page<News> pageNews(Long current, Long size, String categoryCode, String keyword) {
        LambdaQueryWrapper<News> wrapper = new LambdaQueryWrapper<News>()
                .eq(News::getStatus, 1)
                .orderByDesc(News::getPublishTime);
        if (StringUtils.hasText(categoryCode) && !"all".equals(categoryCode)) {
            wrapper.eq(News::getCategoryCode, categoryCode);
        }
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w.like(News::getTitle, keyword)
                    .or().like(News::getSummary, keyword));
        }
        return page(new Page<>(current, size), wrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public News getNewsDetail(Long id) {
        News news = getById(id);
        if (news == null) {
            throw new BusinessException(ResultCode.NEWS_NOT_EXIST);
        }
        // 阅读量 +1（直接 SQL update，避免并发覆盖问题）
        update(new LambdaUpdateWrapper<News>()
                .eq(News::getId, id)
                .setSql("views = views + 1"));
        news.setViews(news.getViews() + 1);
        return news;
    }

    @Override
    public List<NewsCategory> listCategories() {
        return newsCategoryMapper.selectList(new LambdaQueryWrapper<NewsCategory>()
                .orderByAsc(NewsCategory::getSort));
    }

    @Override
    public List<News> listLatest(String categoryCode, Integer limit) {
        if (limit == null || limit <= 0) {
            limit = 5;
        }
        LambdaQueryWrapper<News> wrapper = new LambdaQueryWrapper<News>()
                .eq(News::getStatus, 1)
                .orderByDesc(News::getPublishTime)
                .last("LIMIT " + limit);
        if (StringUtils.hasText(categoryCode)) {
            wrapper.eq(News::getCategoryCode, categoryCode);
        }
        return list(wrapper);
    }
}
