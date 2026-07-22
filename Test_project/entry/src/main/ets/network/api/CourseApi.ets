import { HttpClient } from '../HttpClient';
import { Course } from '../../model/Course';

/**
 * 课程表相关 API
 */
export class CourseApi {
  /** 获取所有课程 */
  static list(): Promise<Course[]> {
    return HttpClient.get<Course[]>('/course/list');
  }

  /** 获取某周某天的课程 */
  static listByDay(dayOfWeek: number, week: number): Promise<Course[]> {
    const params: Record<string, Object> = {
      'dayOfWeek': dayOfWeek as Object,
      'week': week as Object
    };
    return HttpClient.get<Course[]>('/course/listByDay', params);
  }

  /** 获取某周所有课程 */
  static listByWeek(week: number): Promise<Course[]> {
    const params: Record<string, Object> = {
      'week': week as Object
    };
    return HttpClient.get<Course[]>('/course/listByWeek', params);
  }

  /** 获取详情 */
  static detail(id: number): Promise<Course> {
    return HttpClient.get<Course>(`/course/${id}`);
  }

  /** 新增 */
  static add(params: CourseParams): Promise<Course> {
    return HttpClient.post<Course>('/course', JSON.parse(JSON.stringify(params)));
  }

  /** 修改 */
  static update(id: number, params: CourseParams): Promise<Course> {
    return HttpClient.put<Course>(`/course/${id}`, JSON.parse(JSON.stringify(params)));
  }

  /** 删除 */
  static remove(id: number): Promise<void> {
    return HttpClient.delete<void>(`/course/${id}`);
  }
}

export interface CourseParams {
  name: string;
  teacher?: string;
  classroom?: string;
  dayOfWeek: number;
  startSection: number;
  endSection: number;
  weekStart: number;
  weekEnd: number;
  color?: string;
  credit?: number;
  remark?: string;
}
