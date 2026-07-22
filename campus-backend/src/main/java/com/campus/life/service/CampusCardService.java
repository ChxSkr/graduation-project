package com.campus.life.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.life.dto.ConsumeRequest;
import com.campus.life.dto.MonthlySummaryVO;
import com.campus.life.dto.RechargeRequest;
import com.campus.life.entity.CampusCard;
import com.campus.life.entity.CardRecord;

import java.util.List;

/**
 * 校园卡服务接口
 */
public interface CampusCardService extends IService<CampusCard> {

    /**
     * 获取当前用户的校园卡信息
     */
    CampusCard getCurrentCard();

    /**
     * 充值
     */
    CampusCard recharge(RechargeRequest request);

    /**
     * 消费
     */
    CampusCard consume(ConsumeRequest request);

    /**
     * 挂失 / 解挂
     */
    CampusCard toggleLostStatus();

    /**
     * 获取当前用户消费记录列表（可按类型筛选）
     * @param type all/recharge/consume
     */
    List<CardRecord> listRecords(String type);

    /**
     * 获取月度统计
     */
    List<MonthlySummaryVO> getMonthlySummary();
}
