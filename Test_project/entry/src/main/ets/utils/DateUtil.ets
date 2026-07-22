export class DateUtil {
  // 获取当前星期几 (1-7, 1=周一)
  static getCurrentDayOfWeek(): number {
    const day = new Date().getDay();
    return day === 0 ? 7 : day;
  }

  // 学期开始日期（2026年3月1日周一 - 春季学期）
  private static readonly SEMESTER_START_DATE: Date = new Date(2026, 2, 1);

  // 获取当前周次（基于学期开始日期，1-20）
  static getCurrentWeek(): number {
    const now = new Date();
    const start = new Date(DateUtil.SEMESTER_START_DATE);
    // 计算天数差（去掉时分秒影响）
    start.setHours(0, 0, 0, 0);
    now.setHours(0, 0, 0, 0);
    const diffDays = Math.floor((now.getTime() - start.getTime()) / (24 * 60 * 60 * 1000));
    if (diffDays < 0) return 1;
    const week = Math.floor(diffDays / 7) + 1;
    return Math.min(Math.max(week, 1), 20);
  }

  // 获取本周日期数组（周一到周日）
  static getWeekDates(baseDate?: Date): Date[] {
    const date = baseDate ? new Date(baseDate) : new Date();
    const currentDay = date.getDay() === 0 ? 7 : date.getDay();
    const monday = new Date(date);
    monday.setDate(date.getDate() - currentDay + 1);
    const dates: Date[] = [];
    for (let i = 0; i < 7; i++) {
      const d = new Date(monday);
      d.setDate(monday.getDate() + i);
      dates.push(d);
    }
    return dates;
  }

  // 根据周次获取该周的日期数组（周一到周日）
  // 周次基于学期开始日期计算：第1周 = 学期开始那一周
  static getWeekDatesByWeek(week: number): Date[] {
    const start = new Date(DateUtil.SEMESTER_START_DATE);
    const currentDay = start.getDay() === 0 ? 7 : start.getDay();
    const monday = new Date(start);
    monday.setDate(start.getDate() - currentDay + 1);
    monday.setDate(monday.getDate() + (week - 1) * 7);
    const dates: Date[] = [];
    for (let i = 0; i < 7; i++) {
      const d = new Date(monday);
      d.setDate(monday.getDate() + i);
      dates.push(d);
    }
    return dates;
  }

  // 格式化日期 YYYY-MM-DD
  static formatDate(date: Date): string {
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
  }

  // 格式化时间 HH:mm
  static formatTime(date: Date): string {
    const h = String(date.getHours()).padStart(2, '0');
    const m = String(date.getMinutes()).padStart(2, '0');
    return `${h}:${m}`;
  }

  // 格式化日期时间 YYYY-MM-DD HH:mm
  static formatDateTime(date: Date): string {
    return `${DateUtil.formatDate(date)} ${DateUtil.formatTime(date)}`;
  }

  // 获取节次对应的时间
  static getSectionTime(section: number): string {
    const times = [
      '08:00', '08:55', '10:00', '10:55',
      '14:00', '14:55', '16:00', '16:55',
      '19:00', '19:55', '20:50', '21:45'
    ];
    return section >= 1 && section <= 12 ? times[section - 1] : '';
  }

  // 星期几转中文
  static dayOfWeekChinese(day: number): string {
    const days = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return day >= 1 && day <= 7 ? days[day] : '';
  }

  // 获取日期是几号
  static getDayOfMonth(date: Date): number {
    return date.getDate();
  }

  // 获取月份
  static getMonth(date: Date): number {
    return date.getMonth() + 1;
  }

  // 获取当前时间的问候语
  static getGreeting(): string {
    const hour = new Date().getHours();
    if (hour >= 5 && hour < 9) {
      return '早上好';
    } else if (hour >= 9 && hour < 12) {
      return '上午好';
    } else if (hour >= 12 && hour < 14) {
      return '中午好';
    } else if (hour >= 14 && hour < 18) {
      return '下午好';
    } else if (hour >= 18 && hour < 22) {
      return '晚上好';
    } else {
      return '夜深了';
    }
  }

  // 获取首页日期问候字符串，如 "7月11日 星期六 · 上午好"
  static getHomeDateGreeting(): string {
    const now = new Date();
    const month = now.getMonth() + 1;
    const day = now.getDate();
    const dayOfWeek = DateUtil.dayOfWeekChinese(DateUtil.getCurrentDayOfWeek());
    const greeting = DateUtil.getGreeting();
    return `${month}月${day}日 ${dayOfWeek} · ${greeting}`;
  }

  // 获取问候区日期副标题，如 "周三 · 11月20日 · 第12周"
  static getGreetDateSubtitle(): string {
    const now = new Date();
    const month = now.getMonth() + 1;
    const day = now.getDate();
    const dayOfWeek = DateUtil.dayOfWeekChinese(DateUtil.getCurrentDayOfWeek());
    const week = DateUtil.getCurrentWeek();
    return `${dayOfWeek} · ${month}月${day}日 · 第${week}周`;
  }

  // 获取用户名带问候语，如 "早上好，林同学"
  static getGreetingWithName(name: string): string {
    const greeting = DateUtil.getGreeting();
    return `${greeting}，${name}`;
  }
}
