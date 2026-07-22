/**
 * 防抖工具类
 * 用于延迟执行函数，在延迟期间多次调用会重置计时器
 */
export class DebounceUtil {
  private static timers: Map<string, number> = new Map();

  /**
   * 防抖执行
   * @param key 唯一标识
   * @param fn 要执行的函数
   * @param delay 延迟时间（毫秒）
   */
  static debounce(key: string, fn: () => void, delay: number = 300): void {
    // 清除已存在的定时器
    const existingTimer = DebounceUtil.timers.get(key);
    if (existingTimer !== undefined) {
      clearTimeout(existingTimer);
    }

    // 设置新的定时器
    const timer = setTimeout(() => {
      DebounceUtil.timers.delete(key);
      fn();
    }, delay);

    DebounceUtil.timers.set(key, timer);
  }

  /**
   * 立即执行并取消防抖
   * @param key 唯一标识
   * @param fn 要执行的函数
   */
  static immediate(key: string, fn: () => void): void {
    const existingTimer = DebounceUtil.timers.get(key);
    if (existingTimer !== undefined) {
      clearTimeout(existingTimer);
      DebounceUtil.timers.delete(key);
    }
    fn();
  }

  /**
   * 取消防抖
   * @param key 唯一标识
   */
  static cancel(key: string): void {
    const timer = DebounceUtil.timers.get(key);
    if (timer !== undefined) {
      clearTimeout(timer);
      DebounceUtil.timers.delete(key);
    }
  }

  /**
   * 清除所有防抖定时器
   */
  static clearAll(): void {
    DebounceUtil.timers.forEach((timer) => {
      clearTimeout(timer);
    });
    DebounceUtil.timers.clear();
  }
}
