import { Course } from '../model/Course';
import { Logger } from '../utils/Logger';
import { DateUtil } from '../utils/DateUtil';
import { CourseApi, CourseParams } from '../network/api/CourseApi';
import { ApiError } from '../network/HttpClient';

@Observed
export class ScheduleViewModel {
  courseList: Course[] = [];
  currentWeek: number = 1;
  selectedDay: number = 1;
  isLoading: boolean = false;
  totalWeeks: number = 20;

  constructor() {
    this.currentWeek = DateUtil.getCurrentWeek();
    this.selectedDay = DateUtil.getCurrentDayOfWeek();
  }

  /**
   * 从后端加载所有课程
   */
  async loadCourses(): Promise<void> {
    this.isLoading = true;
    try {
      const list = await CourseApi.list();
      this.courseList = list;
      Logger.info('Loaded ' + this.courseList.length + ' courses');
    } catch (e) {
      this.handleApiError(e, 'loadCourses');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 获取某周某天的课程（基于内存中的 courseList 过滤）
   */
  getCoursesByDay(day: number): Course[] {
    return this.courseList.filter(c =>
      c.dayOfWeek === day &&
      this.currentWeek >= c.weekStart &&
      this.currentWeek <= c.weekEnd
    );
  }

  getCourseAt(day: number, section: number): Course | null {
    const courses = this.getCoursesByDay(day);
    for (const c of courses) {
      if (section >= c.startSection && section <= c.endSection) {
        return c;
      }
    }
    return null;
  }

  /**
   * 根据 ID 获取课程（优先从内存找，找不到则请求后端）
   */
  getCourseById(id: string): Course | undefined {
    return this.courseList.find(c => String(c.id) === String(id));
  }

  /**
   * 新增课程（调用后端）
   * @returns 成功返回 true；失败返回 false
   */
  async addCourse(course: Course): Promise<boolean> {
    try {
      const params: CourseParams = {
        name: course.name,
        teacher: course.teacher,
        classroom: course.classroom,
        dayOfWeek: course.dayOfWeek,
        startSection: course.startSection,
        endSection: course.endSection,
        weekStart: course.weekStart,
        weekEnd: course.weekEnd,
        color: course.color,
        credit: course.credit,
        remark: course.remark
      };
      const created = await CourseApi.add(params);
      this.courseList.push(created);
      Logger.info('Course added: ' + course.name);
      return true;
    } catch (e) {
      this.handleApiError(e, 'addCourse');
      return false;
    }
  }

  /**
   * 删除课程
   */
  async deleteCourse(courseId: string): Promise<boolean> {
    try {
      const idNum = Number(courseId);
      if (Number.isNaN(idNum)) {
        Logger.error('Invalid courseId: ' + courseId);
        return false;
      }
      await CourseApi.remove(idNum);
      const index = this.courseList.findIndex(c => String(c.id) === String(courseId));
      if (index > -1) {
        this.courseList.splice(index, 1);
      }
      Logger.info('Course deleted: ' + courseId);
      return true;
    } catch (e) {
      this.handleApiError(e, 'deleteCourse');
      return false;
    }
  }

  /**
   * 修改课程
   */
  async updateCourse(course: Course): Promise<boolean> {
    try {
      const idNum = Number(course.id);
      if (Number.isNaN(idNum)) {
        Logger.error('Invalid courseId: ' + course.id);
        return false;
      }
      const params: CourseParams = {
        name: course.name,
        teacher: course.teacher,
        classroom: course.classroom,
        dayOfWeek: course.dayOfWeek,
        startSection: course.startSection,
        endSection: course.endSection,
        weekStart: course.weekStart,
        weekEnd: course.weekEnd,
        color: course.color,
        credit: course.credit,
        remark: course.remark
      };
      await CourseApi.update(idNum, params);
      const index = this.courseList.findIndex(c => String(c.id) === String(course.id));
      if (index > -1) {
        this.courseList[index] = course;
      }
      return true;
    } catch (e) {
      this.handleApiError(e, 'updateCourse');
      return false;
    }
  }

  setCurrentWeek(week: number): void {
    if (week >= 1 && week <= this.totalWeeks) {
      this.currentWeek = week;
    }
  }

  setSelectedDay(day: number): void {
    if (day >= 1 && day <= 7) {
      this.selectedDay = day;
    }
  }

  nextWeek(): void {
    if (this.currentWeek < this.totalWeeks) {
      this.currentWeek++;
    }
  }

  prevWeek(): void {
    if (this.currentWeek > 1) {
      this.currentWeek--;
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
