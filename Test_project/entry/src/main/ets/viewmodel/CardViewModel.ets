import { CardInfo, ConsumptionRecord } from '../model/CampusCard';
import { Logger } from '../utils/Logger';
import { CardApi } from '../network/api/CardApi';
import { ApiError } from '../network/HttpClient';

export interface MonthlySummary {
  totalRecharge: number;
  totalConsume: number;
}

@Observed
export class CardViewModel {
  cardInfo: CardInfo | null = null;
  records: ConsumptionRecord[] = [];
  isLoading: boolean = false;
  filterType: string = 'all'; // all, recharge, consume

  /**
   * 从后端加载校园卡信息
   */
  async loadCardInfo(): Promise<void> {
    this.isLoading = true;
    try {
      this.cardInfo = await CardApi.getInfo();
      Logger.info('Card info loaded');
    } catch (e) {
      this.handleApiError(e, 'loadCardInfo');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 从后端加载消费记录
   */
  async loadRecords(): Promise<void> {
    try {
      this.records = await CardApi.listRecords();
      Logger.info('Loaded ' + this.records.length + ' records');
    } catch (e) {
      this.handleApiError(e, 'loadRecords');
    }
  }

  /**
   * 充值（调用后端，成功后刷新本地 cardInfo 与 records）
   * @returns 成功返回 true；失败返回 false
   */
  async recharge(amount: number, channel?: string, description?: string): Promise<boolean> {
    if (amount <= 0) {
      Logger.error('recharge: invalid amount ' + amount);
      return false;
    }
    try {
      this.cardInfo = await CardApi.recharge(amount, channel, description);
      // 充值后刷新记录列表，确保记录与新余额一致
      await this.loadRecords();
      Logger.info('Recharge success: ' + amount);
      return true;
    } catch (e) {
      this.handleApiError(e, 'recharge');
      return false;
    }
  }

  getFilteredRecords(): ConsumptionRecord[] {
    if (this.filterType === 'all') {
      return this.records;
    }
    return this.records.filter(r => r.type === this.filterType);
  }

  getRecordsByMonth(): Map<string, ConsumptionRecord[]> {
    const monthMap = new Map<string, ConsumptionRecord[]>();
    const filtered = this.getFilteredRecords();

    for (const record of filtered) {
      // Skip records with undefined or empty time
      if (!record.time || record.time.length < 7) {
        continue;
      }
      const month = record.time.substring(0, 7); // YYYY-MM
      if (!monthMap.has(month)) {
        monthMap.set(month, []);
      }
      monthMap.get(month)!.push(record);
    }

    return monthMap;
  }

  setFilterType(type: string): void {
    this.filterType = type;
  }

  /**
   * 挂失 / 解挂切换（调用后端）
   * @returns 成功返回 true；失败返回 false
   */
  async toggleLostStatus(): Promise<boolean> {
    try {
      this.cardInfo = await CardApi.toggleLost();
      Logger.info('Toggle lost status success, current status: ' + this.cardInfo?.status);
      return true;
    } catch (e) {
      this.handleApiError(e, 'toggleLostStatus');
      return false;
    }
  }

  /**
   * 获取某月汇总（基于内存中的 records 计算）
   */
  getMonthlySummary(month: string): MonthlySummary {
    let totalRecharge = 0;
    let totalConsume = 0;
    const monthRecords = this.records.filter(r => r.time && r.time.startsWith(month));

    for (const r of monthRecords) {
      if (r.type === 'recharge') {
        totalRecharge += r.amount;
      } else {
        totalConsume += Math.abs(r.amount);
      }
    }

    return { totalRecharge, totalConsume };
  }

  /**
   * 统一错误处理
   */
  private handleApiError(e: Object, methodName: string): void {
    const err = e as ApiError;
    Logger.error(`${methodName} failed: code=${err?.code ?? 'unknown'} msg=${err?.message ?? JSON.stringify(e)}`);
  }
}
