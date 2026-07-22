package com.campus.life.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.life.common.BusinessException;
import com.campus.life.common.ResultCode;
import com.campus.life.dto.ConsumeRequest;
import com.campus.life.dto.MonthlySummaryVO;
import com.campus.life.dto.RechargeRequest;
import com.campus.life.entity.CampusCard;
import com.campus.life.entity.CardRecord;
import com.campus.life.mapper.CampusCardMapper;
import com.campus.life.mapper.CardRecordMapper;
import com.campus.life.service.CampusCardService;
import com.campus.life.utils.UserContext;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 校园卡服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CampusCardServiceImpl extends ServiceImpl<CampusCardMapper, CampusCard> implements CampusCardService {

    private final CardRecordMapper cardRecordMapper;

    @Override
    public CampusCard getCurrentCard() {
        Long userId = UserContext.getUserId();
        CampusCard card = getOne(new LambdaQueryWrapper<CampusCard>().eq(CampusCard::getUserId, userId));
        if (card == null) {
            throw new BusinessException(ResultCode.CARD_NOT_EXIST);
        }
        return card;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public CampusCard recharge(RechargeRequest request) {
        CampusCard card = getCurrentCard();
        if ("lost".equals(card.getStatus())) {
            throw new BusinessException(ResultCode.CARD_LOST, "卡片已挂失，无法充值");
        }
        if ("frozen".equals(card.getStatus())) {
            throw new BusinessException(ResultCode.CARD_FROZEN, "卡片已冻结，无法充值");
        }
        card.setBalance(card.getBalance().add(request.getAmount()));
        updateById(card);

        CardRecord record = new CardRecord();
        record.setCardId(card.getId());
        record.setUserId(card.getUserId());
        record.setAmount(request.getAmount());
        record.setType("recharge");
        record.setLocation("线上充值");
        record.setDescription(StringUtils.hasText(request.getDescription()) ? request.getDescription() : request.getChannel() + "充值");
        record.setRecordTime(LocalDateTime.now());
        cardRecordMapper.insert(record);

        log.info("充值成功 | userId={} | amount={} | balance={}", card.getUserId(), request.getAmount(), card.getBalance());
        return card;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public CampusCard consume(ConsumeRequest request) {
        CampusCard card = getCurrentCard();
        if ("lost".equals(card.getStatus())) {
            throw new BusinessException(ResultCode.CARD_LOST, "卡片已挂失，无法消费");
        }
        if ("frozen".equals(card.getStatus())) {
            throw new BusinessException(ResultCode.CARD_FROZEN, "卡片已冻结，无法消费");
        }
        if (card.getBalance().compareTo(request.getAmount()) < 0) {
            throw new BusinessException(ResultCode.BALANCE_NOT_ENOUGH);
        }
        card.setBalance(card.getBalance().subtract(request.getAmount()));
        updateById(card);

        CardRecord record = new CardRecord();
        record.setCardId(card.getId());
        record.setUserId(card.getUserId());
        record.setAmount(request.getAmount().negate());
        record.setType("consume");
        record.setLocation(request.getLocation());
        record.setDescription(request.getDescription());
        record.setRecordTime(LocalDateTime.now());
        cardRecordMapper.insert(record);

        log.info("消费成功 | userId={} | amount={} | balance={}", card.getUserId(), request.getAmount(), card.getBalance());
        return card;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public CampusCard toggleLostStatus() {
        CampusCard card = getCurrentCard();
        if ("normal".equals(card.getStatus())) {
            card.setStatus("lost");
        } else if ("lost".equals(card.getStatus())) {
            card.setStatus("normal");
        } else {
            throw new BusinessException("当前卡片状态不允许此操作");
        }
        updateById(card);
        return card;
    }

    @Override
    public List<CardRecord> listRecords(String type) {
        Long userId = UserContext.getUserId();
        LambdaQueryWrapper<CardRecord> wrapper = new LambdaQueryWrapper<CardRecord>()
                .eq(CardRecord::getUserId, userId)
                .orderByDesc(CardRecord::getRecordTime);
        if (StringUtils.hasText(type) && !"all".equals(type)) {
            wrapper.eq(CardRecord::getType, type);
        }
        return cardRecordMapper.selectList(wrapper);
    }

    @Override
    public List<MonthlySummaryVO> getMonthlySummary() {
        Long userId = UserContext.getUserId();
        List<CardRecord> records = cardRecordMapper.selectList(new LambdaQueryWrapper<CardRecord>()
                .eq(CardRecord::getUserId, userId)
                .orderByDesc(CardRecord::getRecordTime));

        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM");
        Map<String, MonthlySummaryVO> map = new LinkedHashMap<>();
        for (CardRecord r : records) {
            String month = r.getRecordTime().format(fmt);
            MonthlySummaryVO vo = map.computeIfAbsent(month, k -> {
                MonthlySummaryVO s = new MonthlySummaryVO();
                s.setMonth(k);
                s.setTotalRecharge(BigDecimal.ZERO);
                s.setTotalConsume(BigDecimal.ZERO);
                return s;
            });
            if ("recharge".equals(r.getType())) {
                vo.setTotalRecharge(vo.getTotalRecharge().add(r.getAmount()));
            } else {
                vo.setTotalConsume(vo.getTotalConsume().add(r.getAmount().abs()));
            }
        }
        return new ArrayList<>(map.values());
    }
}
