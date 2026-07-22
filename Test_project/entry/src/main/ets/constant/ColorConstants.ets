// 渐变色接口（用于快捷入口等渐变色定义）
export interface GradientColor {
  start: string;
  end: string;
}

// 建筑物轮廓接口（用于城市剪影绘制）
export interface BuildingOutline {
  x: number;
  w: number;
  h: number;
}

// Badge 配置接口
export interface BadgeConfig {
  show: boolean;
  text: string;
}

export class ColorConstants {
  // MARK: - HarmonyOS Design 主色调（深蓝青渐变）
  static readonly PRIMARY = '#0A59F7';
  static readonly PRIMARY_DEEP = '#0033C2';
  static readonly PRIMARY_LIGHT = '#5B9BFF';
  static readonly TEAL = '#00C2CB';
  static readonly TEAL_SOFT = '#7FE3E8';
  static readonly PRIMARY_GRADIENT_START = '#0A59F7';
  static readonly PRIMARY_GRADIENT_END = '#00C2CB';

  // MARK: - 功能色
  static readonly SUCCESS = '#27C49A';
  static readonly WARNING = '#FFB454';
  static readonly ERROR = '#FF6B6B';
  static readonly VIOLET = '#8B6CE6';
  static readonly SKY = '#3FB6FF';
  static readonly ROSE = '#FF8FB1';
  static readonly AMBER = '#FFB454';
  static readonly CORAL = '#FF6B6B';
  static readonly LEAF = '#27C49A';

  // MARK: - iOS 系统色系
  static readonly IOS_BLUE = '#007AFF';
  static readonly IOS_GREEN = '#34C759';
  static readonly IOS_PURPLE = '#AF52DE';
  static readonly IOS_PINK = '#FF2D55';
  static readonly IOS_TEAL = '#5AC8FA';
  static readonly IOS_RED = '#FF3B30';
  static readonly IOS_ORANGE = '#FF9500';
  static readonly IOS_YELLOW = '#FFCC00';

  // MARK: - 文字颜色
  static readonly TEXT_PRIMARY = '#13203B';
  static readonly TEXT_SECONDARY = '#5A6788';
  static readonly TEXT_TERTIARY = '#9AA4BD';
  static readonly TEXT_QUATERNARY = '#C5CBDB';
  static readonly TEXT_DISABLED = '#C5CBDB';

  // MARK: - 背景颜色
  static readonly BG_PAGE = '#EEF1F6';
  static readonly BG_HEADER = '#F4F7FC';
  static readonly BG_CARD = '#FFFFFF';
  static readonly BG_SECONDARY = 'rgba(118, 118, 128, 0.12)';
  static readonly BG_TERTIARY = 'rgba(118, 118, 128, 0.08)';

  // MARK: - 分隔线与边框
  static readonly DIVIDER = '#E9ECF3';
  static readonly DIVIDER_OPAQUE = '#E5E7EB';
  static readonly BORDER = '#E9ECF3';
  static readonly TRANSPARENT = '#00000000';

  // MARK: - TabBar
  static readonly TAB_BAR_BG = 'rgba(255, 255, 255, 0.92)';
  static readonly TAB_BAR_ITEM_NORMAL = '#9AA4BD';
  static readonly TAB_BAR_ITEM_ACTIVE = '#0A59F7';
  static readonly NAV_BAR_BG = 'rgba(247, 247, 247, 0.92)';

  // MARK: - 卡片阴影
  static readonly SHADOW_CARD = 'rgba(20, 40, 90, 0.14)';
  static readonly SHADOW_POP = 'rgba(10, 89, 247, 0.42)';

  // MARK: - 课程卡片颜色调色板（渐变色系）
  static readonly COURSE_COLORS: string[] = [
    '#0A59F7', '#27C49A', '#FFB454', '#8B6CE6',
    '#FF6B6B', '#3FB6FF', '#FF8FB1', '#5856D6'
  ];

  // MARK: - 快捷入口渐变色（8种）
  static readonly QUICK_ENTRY_GRADIENTS: GradientColor[] = [
    { start: '#3FDDB0', end: '#13B589' },
    { start: '#FFC97A', end: '#FF9D2E' },
    { start: '#5B9BFF', end: '#0A59F7' },
    { start: '#A98CF0', end: '#7B5AE0' },
    { start: '#FF9A9E', end: '#FAD0C4' },
    { start: '#7AE8FF', end: '#45B3FF' },
    { start: '#FFD86B', end: '#FFA940' },
    { start: '#8B6CE6', end: '#5B4FC4' }
  ];

  // MARK: - 深色模式
  static readonly DARK_BG_PAGE = '#0A1130';
  static readonly DARK_BG_CARD = '#13203B';
  static readonly DARK_BG_SECONDARY = 'rgba(255, 255, 255, 0.12)';
  static readonly DARK_BG_TERTIARY = 'rgba(255, 255, 255, 0.08)';
  static readonly DARK_TEXT_PRIMARY = '#FFFFFF';
  static readonly DARK_TEXT_SECONDARY = 'rgba(235, 235, 245, 0.6)';
  static readonly DARK_TEXT_TERTIARY = 'rgba(235, 235, 245, 0.3)';
  static readonly DARK_DIVIDER = 'rgba(84, 84, 88, 0.6)';
  static readonly DARK_TAB_BAR_BG = 'rgba(22, 22, 23, 0.92)';
  static readonly DARK_TAB_BAR_ITEM_NORMAL = 'rgba(235, 235, 245, 0.6)';
}
