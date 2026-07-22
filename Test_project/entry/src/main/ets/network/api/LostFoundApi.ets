import { HttpClient } from '../HttpClient';
import { LostFoundItem } from '../../model/LostFound';
import { ApiPageResult } from '../ApiConfig';

/**
 * 失物招领相关 API
 */
export class LostFoundApi {
  /** 分页查询列表 */
  static list(params: ListParams): Promise<ApiPageResult<LostFoundItem>> {
    return HttpClient.get<ApiPageResult<LostFoundItem>>('/lostFound/list', JSON.parse(JSON.stringify(params)));
  }

  /** 我的发布列表（按当前登录用户过滤） */
  static myList(params: MyListParams): Promise<ApiPageResult<LostFoundItem>> {
    return HttpClient.get<ApiPageResult<LostFoundItem>>('/lostFound/my', JSON.parse(JSON.stringify(params)));
  }

  /** 详情 */
  static detail(id: number): Promise<LostFoundItem> {
    return HttpClient.get<LostFoundItem>(`/lostFound/detail/${id}`);
  }

  /** 发布 */
  static publish(params: PublishParams): Promise<LostFoundItem> {
    return HttpClient.post<LostFoundItem>('/lostFound/publish', JSON.parse(JSON.stringify(params)));
  }

  /** 标记为已完成 */
  static complete(id: number): Promise<LostFoundItem> {
    return HttpClient.put<LostFoundItem>(`/lostFound/complete/${id}`);
  }

  /** 删除 */
  static remove(id: number): Promise<void> {
    return HttpClient.delete<void>(`/lostFound/${id}`);
  }
}

export interface ListParams {
  current?: number;
  size?: number;
  type?: string;
  category?: string;
  keyword?: string;
}

export interface MyListParams {
  current?: number;
  size?: number;
  type?: string;
}

export interface PublishParams {
  type: string;
  title: string;
  description: string;
  location: string;
  contact: string;
  category?: string;
  images?: string[];
  eventTime?: string;
}
