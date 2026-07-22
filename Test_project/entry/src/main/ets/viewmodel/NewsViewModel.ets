import { NewsItem, NewsCategory } from '../model/News';
import { PreferencesUtil } from '../utils/PreferencesUtil';
import { PrefKeys } from '../constant/AppConstants';
import { Logger } from '../utils/Logger';
import { NewsApi, PageParams } from '../network/api/NewsApi';
import { ApiError } from '../network/HttpClient';
import { ApiPageResult } from '../network/ApiConfig';

@Observed
export class NewsViewModel {
  newsList: NewsItem[] = [];
  categories: NewsCategory[] = [];
  currentCategory: string = 'all';
  searchKeyword: string = '';
  isLoading: boolean = false;
  isRefreshing: boolean = false;
  isLoadingMore: boolean = false;
  hasMore: boolean = true;
  currentPage: number = 1;
  pageSize: number = 10;
  total: number = 0;
  searchHistory: string[] = [];
  hotSearches: string[] = ['开学典礼', '清明节放假', '校园招聘', '学术报告', '创新创业'];
  listTransitionKey: number = 0;

  constructor() {
    this.loadCategories();
    this.loadSearchHistory();
    this.loadNews();
  }

  /**
   * 从后端加载资讯分类
   */
  async loadCategories(): Promise<void> {
    try {
      this.categories = await NewsApi.categories();
      Logger.info('Loaded ' + this.categories.length + ' categories');
    } catch (e) {
      this.handleApiError(e, 'loadCategories');
    }
  }

  /**
   * 从后端加载第一页资讯（根据当前分类与关键词）
   */
  async loadNews(): Promise<void> {
    this.isLoading = true;
    this.currentPage = 1;
    this.hasMore = true;
    try {
      const params: PageParams = {
        current: this.currentPage,
        size: this.pageSize,
        categoryCode: this.currentCategory !== 'all' ? this.currentCategory : undefined,
        keyword: this.searchKeyword.trim() || undefined
      };
      const page: ApiPageResult<NewsItem> = await NewsApi.page(params);
      this.newsList = page.records || [];
      this.total = page.total || 0;
      this.hasMore = page.current < page.pages;
      Logger.info('Loaded ' + this.newsList.length + ' news, total=' + this.total);
    } catch (e) {
      this.handleApiError(e, 'loadNews');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 下拉刷新（重新加载第一页）
   * @returns 新加载的记录数
   */
  async refreshNews(): Promise<number> {
    this.isRefreshing = true;
    try {
      const before = this.newsList.length;
      await this.loadNews();
      return Math.max(0, this.newsList.length - before);
    } finally {
      this.isRefreshing = false;
    }
  }

  /**
   * 上拉加载更多
   */
  async loadMore(): Promise<void> {
    if (this.isLoadingMore || !this.hasMore) return;
    this.isLoadingMore = true;
    try {
      const next = this.currentPage + 1;
      const params: PageParams = {
        current: next,
        size: this.pageSize,
        categoryCode: this.currentCategory !== 'all' ? this.currentCategory : undefined,
        keyword: this.searchKeyword.trim() || undefined
      };
      const page: ApiPageResult<NewsItem> = await NewsApi.page(params);
      const records = page.records || [];
      this.newsList = this.newsList.concat(records);
      this.currentPage = next;
      this.total = page.total || this.total;
      this.hasMore = page.current < page.pages;
    } catch (e) {
      this.handleApiError(e, 'loadMore');
    } finally {
      this.isLoadingMore = false;
    }
  }

  /**
   * 后端已按分类/关键词过滤并分页，前端直接返回当前内存列表
   */
  getFilteredNews(): NewsItem[] {
    return this.newsList;
  }

  getNewsById(id: string): NewsItem | undefined {
    return this.newsList.find(n => String(n.id) === String(id));
  }

  /**
   * 切换分类，触发重新加载
   */
  setCategory(categoryId: string): void {
    this.currentCategory = categoryId;
    this.listTransitionKey++;
    this.loadNews();
  }

  /**
   * 设置搜索关键词，触发重新加载
   */
  setSearchKeyword(keyword: string): void {
    this.searchKeyword = keyword;
    this.listTransitionKey++;
    this.loadNews();
  }

  /**
   * 阅读量 +1（前端乐观更新；后端在 detail 接口中会自动累加）
   */
  incrementViews(id: string): void {
    const news = this.newsList.find(n => String(n.id) === String(id));
    if (news) {
      news.views++;
    }
  }

  getCategoryName(categoryId: string): string {
    const cat = this.categories.find(c => c.id === categoryId);
    return cat ? cat.name : '';
  }

  // ============ 搜索历史（仍使用本地 Preferences 存储） ============

  loadSearchHistory(): void {
    this.searchHistory = PreferencesUtil.getArray<string>(PrefKeys.SEARCH_HISTORY, []);
  }

  addSearchHistory(keyword: string): void {
    if (!keyword.trim()) return;
    const index = this.searchHistory.indexOf(keyword);
    if (index > -1) {
      this.searchHistory.splice(index, 1);
    }
    this.searchHistory.unshift(keyword);
    if (this.searchHistory.length > 5) {
      this.searchHistory = this.searchHistory.slice(0, 5);
    }
    PreferencesUtil.putArray(PrefKeys.SEARCH_HISTORY, this.searchHistory);
  }

  clearSearchHistory(): void {
    this.searchHistory = [];
    PreferencesUtil.remove(PrefKeys.SEARCH_HISTORY);
  }

  removeSearchHistory(keyword: string): void {
    const index = this.searchHistory.indexOf(keyword);
    if (index > -1) {
      this.searchHistory.splice(index, 1);
      PreferencesUtil.putArray(PrefKeys.SEARCH_HISTORY, this.searchHistory);
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
