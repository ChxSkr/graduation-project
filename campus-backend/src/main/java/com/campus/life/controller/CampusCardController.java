package com.campus.life.controller;

import com.campus.life.common.Result;
import com.campus.life.dto.ConsumeRequest;
import com.campus.life.dto.MonthlySummaryVO;
import com.campus.life.dto.RechargeRequest;
import com.campus.life.entity.CampusCard;
import com.campus.life.entity.CardRecord;
import com.campus.life.service.CampusCardService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 校园卡 Controller
 */
@RestController
@RequestMapping("/card")
@RequiredArgsConstructor
public class CampusCardController {

    private final CampusCardService cardService;

    /**
     * 获取校园卡信息
     * GET /api/card/info
     */
    @GetMapping("/info")
    public Result<CampusCard> getCardInfo() {
        return Result.success(cardService.getCurrentCard());
    }

    /**
     * 充值
     * POST /api/card/recharge
     */
    @PostMapping("/recharge")
    public Result<CampusCard> recharge(@Valid @RequestBody RechargeRequest request) {
        return Result.success(cardService.recharge(request), "充值成功");
    }

    /**
     * 消费
     * POST /api/card/consume
     */
    @PostMapping("/consume")
    public Result<CampusCard> consume(@Valid @RequestBody ConsumeRequest request) {
        return Result.success(cardService.consume(request), "消费成功");
    }

    /**
     * 挂失 / 解挂
     * PUT /api/card/toggleLost
     */
    @PutMapping("/toggleLost")
    public Result<CampusCard> toggleLost() {
        return Result.success(cardService.toggleLostStatus(), "操作成功");
    }

    /**
     * 获取消费记录
     * GET /api/card/records?type=all
     */
    @GetMapping("/records")
    public Result<List<CardRecord>> listRecords(@RequestParam(required = false, defaultValue = "all") String type) {
        return Result.success(cardService.listRecords(type));
    }

    /**
     * 获取月度统计
     * GET /api/card/monthlySummary
     */
    @GetMapping("/monthlySummary")
    public Result<List<MonthlySummaryVO>> getMonthlySummary() {
        return Result.success(cardService.getMonthlySummary());
    }
}
