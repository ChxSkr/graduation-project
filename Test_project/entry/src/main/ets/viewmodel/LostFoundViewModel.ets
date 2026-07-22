import { LostFoundItem, ItemType } from '../model/LostFound';
import { Logger } from '../utils/Logger';
import { LostFoundApi, ListParams, MyListParams, PublishParams } from '../network/api/LostFoundApi';
import { ApiError } from '../network/HttpClient';
import { ApiPageResult } from '../network/ApiConfig';

// 分类接口
export interface Category {
  id: string;
  name: string;
}

@Observed
export class LostFoundViewModel {
  itemList: LostFoundItem[] = [];
  myItemList: LostFoundItem[] = [];
  currentType: ItemType = 'lost';
  currentCategory: string = 'all';
  isLoading: boolean = false;
  isMyLoading: boolean = false;
  searchKeyword: string = '';
  myType: string = 'all';

  categories: Category[] = [
    { id: 'all', name: '全部' },
    { id: '证件', name: '证件' },
    { id: '电子产品', name: '电子产品' },
    { id: '钥匙', name: '钥匙' },
    { id: '书籍', name: '书籍' },
    { id: '其他', name: '其他' }
  ];

  constructor() {
    this.loadItems();
  }

  /**
   * 从后端加载列表（按当前 type/category/keyword 过滤）
   */
  async loadItems(): Promise<void> {
    this.isLoading = true;
    try {
      const params: ListParams = {
        current: 1,
        size: 100,
        type: this.currentType,
        category: this.currentCategory !== 'all' ? this.currentCategory : undefined,
        keyword: this.searchKeyword.trim() || undefined
      };
      const page: ApiPageResult<LostFoundItem> = await LostFoundApi.list(params);
      this.itemList = page.records || [];
      Logger.info('Loaded ' + this.itemList.length + ' lost found items');
    } catch (e) {
      this.handleApiError(e, 'loadItems');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 后端已按 type/category/keyword 过滤，前端直接返回当前内存列表
   */
  getFilteredItems(): LostFoundItem[] {
    return this.itemList;
  }

  /**
   * 加载"我的发布"列表（按当前登录用户过滤）
   */
  async loadMyItems(): Promise<void> {
    this.isMyLoading = true;
    try {
      const params: MyListParams = {
        current: 1,
        size: 100,
        type: this.myType
      };
      const page: ApiPageResult<LostFoundItem> = await LostFoundApi.myList(params);
      this.myItemList = page.records || [];
      Logger.info('Loaded ' + this.myItemList.length + ' my published items');
    } catch (e) {
      this.handleApiError(e, 'loadMyItems');
    } finally {
      this.isMyLoading = false;
    }
  }

  /**
   * 切换"我的发布"页类型筛选，触发重新加载
   */
  setMyType(type: string): void {
    this.myType = type;
    this.loadMyItems();
  }

  getItemById(id: string): LostFoundItem | undefined {
    return this.itemList.find(item => String(item.id) === String(id));
  }

  /**
   * 切换类型，触发重新加载
   */
  setType(type: ItemType): void {
    this.currentType = type;
    this.loadItems();
  }

  /**
   * 切换分类，触发重新加载
   */
  setCategory(category: string): void {
    this.currentCategory = category;
    this.loadItems();
  }

  /**
   * 设置搜索关键词，触发重新加载
   */
  setSearchKeyword(keyword: string): void {
    this.searchKeyword = keyword;
    this.loadItems();
  }

  /**
   * 发布新条目（调用后端）
   * @returns 成功返回 true；失败返回 false
   */
  async publishItem(item: LostFoundItem): Promise<boolean> {
    try {
      const params: PublishParams = {
        type: item.type,
        title: item.title,
        description: item.description,
        location: item.location,
        contact: item.contact,
        category: item.category,
        images: item.images,
        eventTime: item.time
      };
      const created = await LostFoundApi.publish(params);
      // 插入到列表开头，便于 UI 立即反馈
      this.itemList.unshift(created);
      Logger.info('Item published: ' + item.title);
      return true;
    } catch (e) {
      this.handleApiError(e, 'publishItem');
      return false;
    }
  }

  /**
   * 标记为已完成（调用后端）
   * @returns 成功返回 true；失败返回 false
   */
  async completeItem(id: string): Promise<boolean> {
    try {
      const idNum = Number(id);
      if (Number.isNaN(idNum)) {
        Logger.error('completeItem: invalid id ' + id);
        return false;
      }
      const updated = await LostFoundApi.complete(idNum);
      const index = this.itemList.findIndex(i => String(i.id) === String(id));
      if (index > -1) {
        this.itemList[index] = updated;
      }
      return true;
    } catch (e) {
      this.handleApiError(e, 'completeItem');
      return false;
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
