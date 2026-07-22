import { UserInfo } from '../model/User';

export class MockUser {
  static getUserInfo(): UserInfo {
    return {
      id: 'u001',
      name: '张三',
      studentId: '2021001001',
      college: '计算机科学与技术学院',
      major: '软件工程',
      grade: '2021级',
      avatar: '',
      phone: '13800138000',
      email: 'zhangsan@campus.edu.cn'
    };
  }
}
