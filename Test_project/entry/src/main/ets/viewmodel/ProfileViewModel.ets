import { UserInfo } from '../model/User';
import { PreferencesUtil } from '../utils/PreferencesUtil';
import { PrefKeys } from '../constant/AppConstants';
import { Logger } from '../utils/Logger';
import { UserApi, UpdateUserParams } from '../network/api/UserApi';
import { ApiError } from '../network/HttpClient';
import { ApiConfig } from '../network/ApiConfig';

@Observed
export class ProfileViewModel {
  @Track userInfo: UserInfo | null = null;
  @Track isDarkMode: boolean = false;
  @Track isNotificationEnabled: boolean = true;

  // 统计数据
  @Track publishedCount: number = 0;
  @Track favoritesCount: number = 0;
  @Track messagesCount: number = 0;

  // 缓存大小（MB）
  @Track cacheSize: number = 23.5;
  @Track isClearingCache: boolean = false;

  // 字体大小（默认16）
  @Track fontSize: number = 16;

  // 用户信息是否正在加载
  @Track isLoading: boolean = false;

  constructor() {
    this.loadUserInfo();
    this.loadSettings();
  }

  /**
   * 从后端获取当前用户信息
   */
  async loadUserInfo(): Promise<void> {
    if (!ApiConfig.isLoggedIn()) {
      Logger.info('loadUserInfo: not logged in, skip');
      return;
    }
    this.isLoading = true;
    try {
      this.userInfo = await UserApi.getInfo();
      Logger.info('User info loaded: ' + this.userInfo?.name);
      // 同步更新 AppStorage 和 Preferences 中的用户名（确保首页显示一致）
      if (this.userInfo?.name) {
        AppStorage.setOrCreate('userName', this.userInfo.name);
        PreferencesUtil.putString(PrefKeys.USER_NAME, this.userInfo.name);
      }
    } catch (e) {
      this.handleApiError(e, 'loadUserInfo');
    } finally {
      this.isLoading = false;
    }
  }

  loadSettings(): void {
    this.isDarkMode = PreferencesUtil.getBoolean(PrefKeys.DARK_MODE, false);
    // 同步到 AppStorage 用于全局响应
    AppStorage.setOrCreate('darkMode', this.isDarkMode);
    this.isNotificationEnabled = PreferencesUtil.getBoolean(PrefKeys.NOTIFICATION_ENABLED, true);
    this.fontSize = PreferencesUtil.getNumber(PrefKeys.FONT_SIZE, 16);
  }

  /**
   * 修改用户信息（调用后端）
   * @returns 成功返回 true；失败返回 false
   */
  async saveUserInfo(info: UserInfo): Promise<boolean> {
    try {
      const params: UpdateUserParams = {
        name: info.name,
        college: info.college,
        major: info.major,
        grade: info.grade,
        avatar: info.avatar,
        phone: info.phone,
        email: info.email
      };
      this.userInfo = await UserApi.updateInfo(params);
      Logger.info('User info saved: ' + this.userInfo?.name);
      return true;
    } catch (e) {
      this.handleApiError(e, 'saveUserInfo');
      return false;
    }
  }

  /**
   * 修改密码（调用后端）
   * @returns 成功返回 true；失败返回 false
   */
  async changePassword(oldPassword: string, newPassword: string): Promise<boolean> {
    try {
      await UserApi.changePassword(oldPassword, newPassword);
      Logger.info('Password changed');
      return true;
    } catch (e) {
      this.handleApiError(e, 'changePassword');
      return false;
    }
  }

  /**
   * 退出登录：清除本地 token 与用户信息
   */
  logout(): void {
    ApiConfig.clearToken();
    this.userInfo = null;
    AppStorage.setOrCreate('isLoggedIn', false);
    AppStorage.setOrCreate('studentId', '');
    Logger.info('User logged out');
  }

  toggleDarkMode(): void {
    this.isDarkMode = !this.isDarkMode;
    PreferencesUtil.putBoolean(PrefKeys.DARK_MODE, this.isDarkMode);
    AppStorage.setOrCreate('darkMode', this.isDarkMode);
  }

  toggleNotification(): void {
    this.isNotificationEnabled = !this.isNotificationEnabled;
    PreferencesUtil.putBoolean(PrefKeys.NOTIFICATION_ENABLED, this.isNotificationEnabled);
  }

  setFontSize(size: number): void {
    this.fontSize = size;
    PreferencesUtil.putNumber(PrefKeys.FONT_SIZE, size);
    AppStorage.setOrCreate('fontSize', size);
  }

  clearCache(callback?: () => void): void {
    if (this.isClearingCache) return;
    this.isClearingCache = true;
    // 模拟清除动画：缓存大小逐步减到0
    const totalSteps = 10;
    const stepSize = this.cacheSize / totalSteps;
    let currentStep = 0;
    const interval = setInterval(() => {
      currentStep++;
      this.cacheSize = Math.max(0, this.cacheSize - stepSize);
      if (currentStep >= totalSteps) {
        clearInterval(interval);
        this.cacheSize = 0;
        this.isClearingCache = false;
        Logger.info('Cache cleared');
        if (callback) {
          callback();
        }
      }
    }, 50);
  }

  getCacheSizeText(): string {
    if (this.cacheSize < 1) {
      return (this.cacheSize * 1024).toFixed(0) + ' KB';
    }
    return this.cacheSize.toFixed(1) + ' MB';
  }

  checkUpdate(): boolean {
    // 模拟检查更新，返回true表示已是最新
    Logger.info('Checking update...');
    return true;
  }

  getAppVersion(): string {
    return '1.0.0';
  }

  /**
   * 刷新用户数据（重新拉取用户信息）
   */
  async refreshData(callback?: () => void): Promise<void> {
    await this.loadUserInfo();
    if (callback) {
      callback();
    }
  }

  /**
   * 统一错误处理
   */
  private handleApiError(e: Object, methodName: string): void {
    const err = e as ApiError;
    Logger.error(`${methodName} failed: code=${err?.code ?? 'unknown'} msg=${err?.message ?? JSON.stringify(e)}`);
  }
}
