import { HttpClient } from '../HttpClient';
import { UserInfo } from '../../model/User';

/**
 * 用户相关 API
 */
export class UserApi {
  /** 获取当前用户信息 */
  static getInfo(): Promise<UserInfo> {
    return HttpClient.get<UserInfo>('/user/info');
  }

  /** 修改用户信息 */
  static updateInfo(params: UpdateUserParams): Promise<UserInfo> {
    const body: Record<string, Object> = {};
    if (params.name) body['name'] = params.name as Object;
    if (params.college) body['college'] = params.college as Object;
    if (params.major) body['major'] = params.major as Object;
    if (params.grade) body['grade'] = params.grade as Object;
    if (params.avatar) body['avatar'] = params.avatar as Object;
    if (params.phone) body['phone'] = params.phone as Object;
    if (params.email) body['email'] = params.email as Object;
    return HttpClient.put<UserInfo>('/user/info', body);
  }

  /** 修改密码 */
  static changePassword(oldPassword: string, newPassword: string): Promise<void> {
    const params: Record<string, Object> = {
      'oldPassword': oldPassword as Object,
      'newPassword': newPassword as Object
    };
    return HttpClient.put<void>('/user/password', params);
  }
}

export interface UpdateUserParams {
  name?: string;
  college?: string;
  major?: string;
  grade?: string;
  avatar?: string;
  phone?: string;
  email?: string;
}
