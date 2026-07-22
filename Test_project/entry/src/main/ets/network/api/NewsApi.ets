import { HttpClient } from '../HttpClient';
import { NewsItem, NewsCategory } from '../../model/News';
import { ApiPageResult } from '../ApiConfig';

/**
 * 资讯相关 API
 */
export class NewsApi {
  /** 分页查询资讯 */
  static page(params: PageParams): Promise<ApiPageResult<NewsItem>> {
    return HttpClient.get<ApiPageResult<NewsItem>>('/news/page', JSON.parse(JSON.stringify(params)));
  }

  /** 获取所有分类 */
  static categories(): Promise<NewsCategory[]> {
    return HttpClient.get<NewsCategory[]>('/news/categories');
  }

  /** 获取详情 */
  static detail(id: number): Promise<NewsItem> {
    return HttpClient.get<NewsItem>(`/news/${id}`);
  }

  /** 最新 N 条 */
  static latest(categoryCode?: string, limit?: number): Promise<NewsItem[]> {
    const params: Record<string, Object> = {};
    if (categoryCode) params.categoryCode = categoryCode;
    if (limit) params.limit = limit;
    return HttpClient.get<NewsItem[]>('/news/latest', params);
  }
}

export interface PageParams {
  current?: number;
  size?: number;
  categoryCode?: string;
  keyword?: string;
}
