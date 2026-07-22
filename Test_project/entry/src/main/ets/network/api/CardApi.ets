import { HttpClient } from '../HttpClient';
import { CardInfo, ConsumptionRecord } from '../../model/CampusCard';

/**
 * 校园卡相关 API
 */
export class CardApi {
  /** 获取卡信息 */
  static getInfo(): Promise<CardInfo> {
    return HttpClient.get<CardInfo>('/card/info');
  }

  /** 充值 */
  static recharge(amount: number, channel?: string, description?: string): Promise<CardInfo> {
    const params: Record<string, Object> = {
      'amount': amount as Object,
      'channel': (channel || '') as Object,
      'description': (description || '') as Object
    };
    return HttpClient.post<CardInfo>('/card/recharge', params);
  }

  /** 消费 */
  static consume(amount: number, location: string, description?: string): Promise<CardInfo> {
    const params: Record<string, Object> = {
      'amount': amount as Object,
      'location': location as Object,
      'description': (description || '') as Object
    };
    return HttpClient.post<CardInfo>('/card/consume', params);
  }

  /** 挂失 / 解挂 */
  static toggleLost(): Promise<CardInfo> {
    return HttpClient.put<CardInfo>('/card/toggleLost');
  }

  /** 消费记录列表 */
  static listRecords(type?: string): Promise<ConsumptionRecord[]> {
    const params: Record<string, Object> = {
      'type': (type || 'all') as Object
    };
    return HttpClient.get<ConsumptionRecord[]>('/card/records', params);
  }

  /** 月度统计 */
  static monthlySummary(): Promise<MonthlySummary[]> {
    return HttpClient.get<MonthlySummary[]>('/card/monthlySummary');
  }
}

export interface MonthlySummary {
  month: string;
  totalRecharge: number;
  totalConsume: number;
}
