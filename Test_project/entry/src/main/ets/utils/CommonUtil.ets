import promptAction from '@ohos.promptAction';

export class CommonUtil {
  // 金额格式化（保留2位小数）
  static formatMoney(amount: number): string {
    return amount.toFixed(2);
  }

  // 卡号脱敏（显示前4后4，中间用*代替）
  static maskCardNo(cardNo: string): string {
    if (cardNo.length <= 8) return cardNo;
    return cardNo.substring(0, 4) + ' **** **** ' + cardNo.substring(cardNo.length - 4);
  }

  // 显示 Toast
  static showToast(message: string): void {
    promptAction.showToast({ message: message, duration: 1500 });
  }

  // 生成唯一ID
  static generateId(): string {
    return Date.now().toString(36) + Math.random().toString(36).substring(2, 8);
  }

  // 复制到剪贴板
  static copyToClipboard(text: string): void {
    // 使用 @ohos.pasteboard 模块
    // 简化实现，后续完善
    CommonUtil.showToast('已复制：' + text);
  }

  // 手机号脱敏
  static maskPhone(phone: string): string {
    if (phone.length !== 11) return phone;
    return phone.substring(0, 3) + '****' + phone.substring(7);
  }
}
