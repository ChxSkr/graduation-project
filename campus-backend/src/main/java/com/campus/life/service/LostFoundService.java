package com.campus.life.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.life.dto.LostFoundRequest;
import com.campus.life.entity.LostFound;

/**
 * 失物招领服务接口
 */
public interface LostFoundService extends IService<LostFound> {

    /**
     * 分页查询失物招领列表
     * @param current 当前页
     * @param size 每页数量
     * @param type 类型：lost/found
     * @param category 分类
     * @param keyword 关键词（标题/地点）
     */
    Page<LostFound> pageList(Long current, Long size, String type, String category, String keyword);

    /**
     * 我的发布列表（按当前登录用户 userId 过滤）
     * @param current 当前页
     * @param size 每页数量
     * @param type 类型：lost/found/all
     */
    Page<LostFound> myList(Long current, Long size, String type);

    /**
     * 获取详情
     */
    LostFound getDetail(Long id);

    /**
     * 发布失物招领
     */
    LostFound publish(LostFoundRequest request);

    /**
     * 标记为已完成
     */
    LostFound complete(Long id);

    /**
     * 删除（仅本人）
     */
    void delete(Long id);
}
