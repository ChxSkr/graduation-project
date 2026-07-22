import { QuickEntry } from '../model/QuickEntry';
import { NewsItem } from '../model/News';
import { Course } from '../model/Course';
import { CardInfo } from '../model/CampusCard';
import { UserInfo } from '../model/User';
import { DateUtil } from '../utils/DateUtil';
import { Logger } from '../utils/Logger';
import { NewsApi } from '../network/api/NewsApi';
import { CourseApi } from '../network/api/CourseApi';
import { CardApi } from '../network/api/CardApi';
import { ApiError } from '../network/HttpClient';
import { ApiConfig } from '../network/ApiConfig';
import { UserApi } from '../network/api/UserApi';
import { PreferencesUtil } from '../utils/PreferencesUtil';
import { PrefKeys } from '../constant/AppConstants';

@Observed
export class HomeViewModel {
  quickEntries: QuickEntry[] = [];
  bannerList: NewsItem[] = [];
  todayCourses: Course[] = [];
  noticeList: NewsItem[] = [];
  cardInfo: CardInfo | null = null;
  userInfo: UserInfo | null = null;
  isLoading: boolean = false;

  constructor() {
    this.loadQuickEntries();
    this.refresh();
  }

  loadQuickEntries(): void {
    this.quickEntries = [
      { id: 'qe1', name: '图书馆', icon: '📚', targetTab: 3 },
      { id: 'qe2', name: '课表', icon: '📅', targetTab: 1 },
      { id: 'qe3', name: '成绩', icon: '📊', targetTab: 1 }
    ];
  }

  /**
   * 加载校园资讯 Banner（最新 3 条 campus 分类）
   */
  async loadBannerNews(): Promise<void> {
    try {
      this.bannerList = await NewsApi.latest('campus', 3);
    } catch (e) {
      this.handleApiError(e, 'loadBannerNews');
    }
  }

  /**
   * 加载今日课程（按当前周次与星期几）
   */
  async loadTodayCourses(): Promise<void> {
    if (!ApiConfig.isLoggedIn()) {
      Logger.info('loadTodayCourses: not logged in, skip');
      return;
    }
    try {
      const today = DateUtil.getCurrentDayOfWeek();
      const currentWeek = DateUtil.getCurrentWeek();
      const list = await CourseApi.listByDay(today, currentWeek);
      this.todayCourses = list.sort((a, b) => a.startSection - b.startSection);
      Logger.info('Today courses: ' + this.todayCourses.length);
    } catch (e) {
      this.handleApiError(e, 'loadTodayCourses');
    }
  }

  /**
   * 加载通知公告（最新 5 条 notice 分类）
   */
  async loadNotices(): Promise<void> {
    try {
      this.noticeList = await NewsApi.latest('notice', 5);
    } catch (e) {
      this.handleApiError(e, 'loadNotices');
    }
  }

  /**
   * 加载用户信息（确保首页显示的用户名是最新的）
   */
  async loadUserInfo(): Promise<void> {
    if (!ApiConfig.isLoggedIn()) {
      return;
    }
    try {
      const userInfo = await UserApi.getInfo();
      this.userInfo = userInfo;
      if (userInfo?.name) {
        AppStorage.setOrCreate('userName', userInfo.name);
        PreferencesUtil.putString(PrefKeys.USER_NAME, userInfo.name);
        Logger.info('User info synced: ' + userInfo.name);
      }
    } catch (e) {
      this.handleApiError(e, 'loadUserInfo');
    }
  }

  /**
   * 加载校园卡信息
   */
  async loadCardInfo(): Promise<void> {
    if (!ApiConfig.isLoggedIn()) {
      return;
    }
    try {
      this.cardInfo = await CardApi.getInfo();
      Logger.info('Card info loaded: ' + this.cardInfo?.cardNo);
    } catch (e) {
      this.handleApiError(e, 'loadCardInfo');
    }
  }

  /**
   * 刷新所有数据（并行加载）
   */
  async refresh(): Promise<void> {
    this.isLoading = true;
    try {
      await Promise.all([
        this.loadBannerNews(),
        this.loadTodayCourses(),
        this.loadNotices(),
        this.loadUserInfo(),
        this.loadCardInfo()
      ]);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 兼容旧调用：异步刷新（与 refresh 等价）
   */
  async refreshAsync(): Promise<void> {
    await this.refresh();
  }

  /**
   * 统一错误处理
   */
  private handleApiError(e: Object, methodName: string): void {
    const err = e as ApiError;
    Logger.error(`${methodName} failed: code=${err?.code ?? 'unknown'} msg=${err?.message ?? JSON.stringify(e)}`);
  }
}
