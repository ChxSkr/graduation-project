package com.campus.life.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.life.common.BusinessException;
import com.campus.life.common.ResultCode;
import com.campus.life.dto.LostFoundRequest;
import com.campus.life.entity.LostFound;
import com.campus.life.mapper.LostFoundMapper;
import com.campus.life.service.LostFoundService;
import com.campus.life.utils.UserContext;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.stream.Collectors;

/**
 * 失物招领服务实现
 */
@Slf4j
@Service
public class LostFoundServiceImpl extends ServiceImpl<LostFoundMapper, LostFound> implements LostFoundService {

    @Override
    public Page<LostFound> pageList(Long current, Long size, String type, String category, String keyword) {
        LambdaQueryWrapper<LostFound> wrapper = new LambdaQueryWrapper<LostFound>()
                .orderByDesc(LostFound::getPublishTime);
        if (StringUtils.hasText(type) && !"all".equals(type)) {
            wrapper.eq(LostFound::getType, type);
        }
        if (StringUtils.hasText(category) && !"all".equals(category)) {
            wrapper.eq(LostFound::getCategory, category);
        }
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w.like(LostFound::getTitle, keyword)
                    .or().like(LostFound::getLocation, keyword));
        }
        return page(new Page<>(current, size), wrapper);
    }

    @Override
    public Page<LostFound> myList(Long current, Long size, String type) {
        Long userId = UserContext.getUserId();
        if (userId == null) {
            throw new BusinessException(ResultCode.UNAUTHORIZED, "未登录");
        }
        LambdaQueryWrapper<LostFound> wrapper = new LambdaQueryWrapper<LostFound>()
                .eq(LostFound::getUserId, userId)
                .orderByDesc(LostFound::getPublishTime);
        if (StringUtils.hasText(type) && !"all".equals(type)) {
            wrapper.eq(LostFound::getType, type);
        }
        return page(new Page<>(current, size), wrapper);
    }

    @Override
    public LostFound getDetail(Long id) {
        LostFound item = getById(id);
        if (item == null) {
            throw new BusinessException(ResultCode.LOST_FOUND_NOT_EXIST);
        }
        return item;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public LostFound publish(LostFoundRequest request) {
        if (!"lost".equals(request.getType()) && !"found".equals(request.getType())) {
            throw new BusinessException("类型必须为 lost 或 found");
        }
        LostFound item = new LostFound();
        BeanUtils.copyProperties(request, item);
        item.setUserId(UserContext.getUserId());
        item.setStatus("active");
        item.setPublishTime(LocalDateTime.now());
        if (request.getEventTime() == null) {
            item.setEventTime(LocalDateTime.now());
        }
        if (!CollectionUtils.isEmpty(request.getImages())) {
            item.setImages(request.getImages().stream().collect(Collectors.joining(",")));
        }
        save(item);
        log.info("发布失物招领 | userId={} | id={} | type={}", item.getUserId(), item.getId(), item.getType());
        return item;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public LostFound complete(Long id) {
        LostFound item = getOwnedItem(id);
        item.setStatus("completed");
        updateById(item);
        return item;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        LostFound item = getOwnedItem(id);
        removeById(item.getId());
    }

    /**
     * 获取当前用户拥有的失物招领信息
     */
    private LostFound getOwnedItem(Long id) {
        LostFound item = getById(id);
        if (item == null) {
            throw new BusinessException(ResultCode.LOST_FOUND_NOT_EXIST);
        }
        Long currentUserId = UserContext.getUserId();
        if (currentUserId == null || !item.getUserId().equals(currentUserId)) {
            throw new BusinessException(ResultCode.FORBIDDEN, "无权操作此信息");
        }
        return item;
    }
}
