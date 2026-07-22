import { HttpClient, RequestOptions } from '../HttpClient';
import { UserInfo } from '../../model/User';

/**
 * 认证相关 API
 */
export class AuthApi {
  /** 登录请求参数 */
  static login(studentId: string, password: string): Promise<LoginResponse> {
    const loginParams: Record<string, Object> = {
      'studentId': studentId as Object,
      'password': password as Object
    };
    const options: RequestOptions = {
      skipAuth: true
    };
    return HttpClient.post<LoginResponse>('/auth/login', loginParams, options);
  }

  /** 注册 */
  static register(params: RegisterParams): Promise<UserInfo> {
    const options: RequestOptions = {
      skipAuth: true
    };
    return HttpClient.post<UserInfo>('/auth/register', JSON.parse(JSON.stringify(params)), options);
  }
}

/** 登录响应 */
export interface LoginResponse {
  token: string;
  tokenPrefix: string;
  expiresIn: number;
  userInfo: UserInfo;
}

/** 注册参数 */
export interface RegisterParams {
  studentId: string;
  password: string;
  name: string;
  college?: string;
  major?: string;
  grade?: string;
  phone?: string;
  email?: string;
}
