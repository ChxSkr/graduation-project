import http from '@ohos.net.http';
import { ApiConfig, ApiResult } from './ApiConfig';
import { Logger } from '../utils/Logger';

/**
 * HTTP 客户端工具类
 * 基于 @ohos.net.http 封装，提供 GET/POST/PUT/DELETE 方法
 * 自动处理 JWT Token 注入、统一响应解析、错误处理
 */
export class HttpClient {
  /**
   * 通用请求方法
   * @param method 请求方法 GET/POST/PUT/DELETE
   * @param path 接口路径（不含 baseURL，如 /user/info）
   * @param data 请求参数（GET/DELETE 作为 query；POST/PUT 作为 body）
   * @param options 可选配置
   */
  static request<T>(
    method: http.RequestMethod,
    path: string,
    data?: Record<string, Object> | string,
    options?: RequestOptions
  ): Promise<T> {
    return new Promise<T>((resolve, reject) => {
      const url = ApiConfig.buildUrl(path);
      const httpReq = http.createHttp();

      // 构造 header
      const header: Record<string, string> = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };

      // 注入 Token
      const token = ApiConfig.getToken();
      if (token && !(options && options.skipAuth)) {
        header['Authorization'] = 'Bearer ' + token;
      }

      // 附加自定义 header
      if (options && options.headers) {
        for (const key of Object.keys(options.headers)) {
          header[key] = options.headers[key];
        }
      }

      // 请求体
      let body: string = '';
      if (data && (method === http.RequestMethod.POST || method === http.RequestMethod.PUT)) {
        // POST/PUT：参数放 body
        body = typeof data === 'string' ? data : JSON.stringify(data);
      }

      // 处理成功响应（箭头函数）
      const handleSuccess = (resp: http.HttpResponse): void => {
        try {
          httpReq.destroy();
          const statusCode = resp.responseCode;
          const resultStr = typeof resp.result === 'string' ? resp.result : JSON.stringify(resp.result);
          Logger.debug(`HTTP [${method}] ${path} → ${statusCode}`);

          if (statusCode === 401) {
            // Token 失效，清除并返回未登录错误
            ApiConfig.clearToken();
            const err: ApiError = { code: 401, message: '未登录或登录已过期', path: path };
            reject(err);
            return;
          }

          if (statusCode < 200 || statusCode >= 300) {
            const err: ApiError = {
              code: statusCode,
              message: HttpClient.tryParseMessage(resultStr) || `请求失败 (${statusCode})`,
              path: path
            };
            reject(err);
            return;
          }

          // 解析后端统一响应
          const result: ApiResult<T> = JSON.parse(resultStr);
          if (result.code !== 200 && result.code !== 201) {
            const err: ApiError = {
              code: result.code,
              message: result.message || '业务处理失败',
              path: path
            };
            reject(err);
            return;
          }

          resolve(result.data);
        } catch (e) {
          Logger.error(`HTTP 响应解析失败: ${JSON.stringify(e)} | path=${path}`);
          const err: ApiError = {
            code: 500,
            message: '响应解析失败',
            path: path
          };
          reject(err);
        }
      };

      // 处理网络错误（箭头函数）
      const handleError = (reason: Error): void => {
        httpReq.destroy();
        Logger.error(`HTTP 请求失败 [${method}] ${path}: ${reason.message}`);
        const err: ApiError = {
          code: -1,
          message: '网络连接失败，请检查网络后重试',
          path: path
        };
        reject(err);
      };

      // 发起请求
      if (method === http.RequestMethod.GET || method === http.RequestMethod.DELETE) {
        // GET/DELETE：参数拼到 query
        const queryStr = data ? HttpClient.buildQuery(data as Record<string, Object>) : '';
        const finalUrl = queryStr ? url + (url.includes('?') ? '&' : '?') + queryStr : url;
        const options: http.HttpRequestOptions = {
          method: method,
          header: header,
          connectTimeout: ApiConfig.TIMEOUT,
          readTimeout: ApiConfig.TIMEOUT,
          expectDataType: http.HttpDataType.STRING
        };
        httpReq.request(finalUrl, options).then(handleSuccess).catch(handleError);
      } else {
        // POST/PUT：参数放 body
        const options: http.HttpRequestOptions = {
          method: method,
          header: header,
          extraData: body,
          connectTimeout: ApiConfig.TIMEOUT,
          readTimeout: ApiConfig.TIMEOUT,
          expectDataType: http.HttpDataType.STRING
        };
        httpReq.request(url, options).then(handleSuccess).catch(handleError);
      }
    });
  }

  /**
   * GET 请求
   */
  static get<T>(path: string, params?: Record<string, Object>, options?: RequestOptions): Promise<T> {
    return HttpClient.request<T>(http.RequestMethod.GET, path, params, options);
  }

  /**
   * POST 请求
   */
  static post<T>(path: string, body?: Record<string, Object> | string, options?: RequestOptions): Promise<T> {
    return HttpClient.request<T>(http.RequestMethod.POST, path, body, options);
  }

  /**
   * PUT 请求
   */
  static put<T>(path: string, body?: Record<string, Object>, options?: RequestOptions): Promise<T> {
    return HttpClient.request<T>(http.RequestMethod.PUT, path, body, options);
  }

  /**
   * DELETE 请求
   */
  static delete<T>(path: string, params?: Record<string, Object>, options?: RequestOptions): Promise<T> {
    return HttpClient.request<T>(http.RequestMethod.DELETE, path, params, options);
  }

  /**
   * 将对象拼为 query string
   */
  private static buildQuery(params: Record<string, Object>): string {
    if (!params || Object.keys(params).length === 0) {
      return '';
    }
    const parts: string[] = [];
    for (const key of Object.keys(params)) {
      const val = params[key];
      if (val === undefined || val === null) continue;
      parts.push(encodeURIComponent(key) + '=' + encodeURIComponent(String(val)));
    }
    return parts.join('&');
  }

  /**
   * 尝试从错误响应体中提取 message
   */
  private static tryParseMessage(str: string): string {
    try {
      const obj: Record<string, Object> = JSON.parse(str);
      if (obj && typeof obj.message === 'string') {
        return obj.message as string;
      }
    } catch (e) {
      // ignore
    }
    return '';
  }
}

/**
 * 请求附加选项
 */
export interface RequestOptions {
  /** 跳过 Token 注入（用于登录/注册接口） */
  skipAuth?: boolean;
  /** 自定义请求头 */
  headers?: Record<string, string>;
}

/**
 * API 错误
 */
export interface ApiError {
  code: number;
  message: string;
  path: string;
}
