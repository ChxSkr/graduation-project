import { PreferencesUtil } from '../utils/PreferencesUtil';

/**
 * 后端 API 配置
 */
export class ApiConfig {
  /** 后端服务器基础地址（实际部署时修改为真实 IP） */
  static readonly BASE_URL: string = 'http://192.168.3.17:8080/api';

  /** 请求超时时间（毫秒） */
  static readonly TIMEOUT: number = 15000;

  /** Token 相关存储 key */
  static readonly TOKEN_KEY: string = 'auth_token';

  /**
   * 获取完整 URL
   */
  static buildUrl(path: string): string {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return ApiConfig.BASE_URL + (path.startsWith('/') ? path : '/' + path);
  }

  /**
   * 保存 token
   */
  static saveToken(token: string): void {
    PreferencesUtil.putString(ApiConfig.TOKEN_KEY, token);
  }

  /**
   * 获取 token
   */
  static getToken(): string {
    return PreferencesUtil.getString(ApiConfig.TOKEN_KEY, '');
  }

  /**
   * 清除 token
   */
  static clearToken(): void {
    PreferencesUtil.remove(ApiConfig.TOKEN_KEY);
  }

  /**
   * 判断是否已登录
   */
  static isLoggedIn(): boolean {
    return ApiConfig.getToken().length > 0;
  }
}

/**
 * 统一响应结构（与后端 Result<T> 对应）
 */
export interface ApiResult<T> {
  code: number;
  message: string;
  data: T;
  timestamp?: number;
}

/**
 * 分页响应结构（与后端 PageResult<T> 对应）
 */
export interface ApiPageResult<T> {
  records: T[];
  total: number;
  current: number;
  size: number;
  pages: number;
}
