package com.campus.life.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.life.common.PageResult;
import com.campus.life.common.Result;
import com.campus.life.dto.LostFoundRequest;
import com.campus.life.entity.LostFound;
import com.campus.life.service.LostFoundService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 失物招领 Controller
 * 路径前缀：/lostFound
 * - /lostFound/list 公开浏览
 * - /lostFound/detail/{id} 公开浏览
 * - 其他接口需登录
 */
@RestController
@RequestMapping("/lostFound")
@RequiredArgsConstructor
public class LostFoundController {

    private final LostFoundService lostFoundService;

    /**
     * 分页查询失物招领列表
     * GET /api/lostFound/list?type=lost&category=证件&keyword=&current=1&size=10
     */
    @GetMapping("/list")
    public Result<PageResult<LostFound>> list(@RequestParam(required = false, defaultValue = "1") Long current,
                                              @RequestParam(required = false, defaultValue = "10") Long size,
                                              @RequestParam(required = false, defaultValue = "all") String type,
                                              @RequestParam(required = false, defaultValue = "all") String category,
                                              @RequestParam(required = false) String keyword) {
        Page<LostFound> page = lostFoundService.pageList(current, size, type, category, keyword);
        return Result.success(PageResult.of(page));
    }

    /**
     * 我的发布列表（需登录，按当前用户 userId 过滤）
     * GET /api/lostFound/my?type=lost&current=1&size=10
     */
    @GetMapping("/my")
    public Result<PageResult<LostFound>> my(@RequestParam(required = false, defaultValue = "1") Long current,
                                            @RequestParam(required = false, defaultValue = "10") Long size,
                                            @RequestParam(required = false, defaultValue = "all") String type) {
        Page<LostFound> page = lostFoundService.myList(current, size, type);
        return Result.success(PageResult.of(page));
    }

    /**
     * 获取详情
     * GET /api/lostFound/detail/{id}
     */
    @GetMapping("/detail/{id}")
    public Result<LostFound> detail(@PathVariable Long id) {
        return Result.success(lostFoundService.getDetail(id));
    }

    /**
     * 发布
     * POST /api/lostFound/publish
     */
    @PostMapping("/publish")
    public Result<LostFound> publish(@Valid @RequestBody LostFoundRequest request) {
        return Result.success(lostFoundService.publish(request), "发布成功");
    }

    /**
     * 标记为已完成
     * PUT /api/lostFound/complete/{id}
     */
    @PutMapping("/complete/{id}")
    public Result<LostFound> complete(@PathVariable Long id) {
        return Result.success(lostFoundService.complete(id), "操作成功");
    }

    /**
     * 删除
     * DELETE /api/lostFound/{id}
     */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        lostFoundService.delete(id);
        return Result.success(null, "删除成功");
    }
}
