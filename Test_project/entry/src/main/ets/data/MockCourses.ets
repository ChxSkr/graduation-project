import { Course } from '../model/Course';
import { ColorConstants } from '../constant/ColorConstants';

export class MockCourses {
  static getInitialCourses(): Course[] {
    const colors = ColorConstants.COURSE_COLORS;
    return [
      {
        id: 'c001', name: '数据结构', teacher: '王教授', classroom: '教1-201',
        dayOfWeek: 1, startSection: 1, endSection: 2,
        weekStart: 1, weekEnd: 16, color: colors[0], credit: 4,
        remark: '专业必修课'
      },
      {
        id: 'c002', name: '计算机网络', teacher: '李教授', classroom: '教2-305',
        dayOfWeek: 1, startSection: 5, endSection: 6,
        weekStart: 1, weekEnd: 16, color: colors[1], credit: 3,
        remark: '专业必修课'
      },
      {
        id: 'c003', name: '操作系统', teacher: '张教授', classroom: '教3-102',
        dayOfWeek: 2, startSection: 3, endSection: 4,
        weekStart: 1, weekEnd: 16, color: colors[2], credit: 4,
        remark: '专业必修课'
      },
      {
        id: 'c004', name: '数据库原理', teacher: '刘教授', classroom: '教1-401',
        dayOfWeek: 2, startSection: 7, endSection: 8,
        weekStart: 2, weekEnd: 17, color: colors[3], credit: 3.5,
        remark: '专业必修课'
      },
      {
        id: 'c005', name: '软件工程', teacher: '陈教授', classroom: '教2-203',
        dayOfWeek: 3, startSection: 1, endSection: 2,
        weekStart: 1, weekEnd: 15, color: colors[4], credit: 3,
        remark: '专业必修课'
      },
      {
        id: 'c006', name: '算法设计与分析', teacher: '赵教授', classroom: '教1-305',
        dayOfWeek: 3, startSection: 5, endSection: 6,
        weekStart: 2, weekEnd: 17, color: colors[5], credit: 3,
        remark: '专业选修课'
      },
      {
        id: 'c007', name: '大学英语', teacher: '周老师', classroom: '外语楼-201',
        dayOfWeek: 4, startSection: 1, endSection: 2,
        weekStart: 1, weekEnd: 16, color: colors[6], credit: 2,
        remark: '公共必修课'
      },
      {
        id: 'c008', name: '高等数学', teacher: '吴教授', classroom: '教1-101',
        dayOfWeek: 4, startSection: 3, endSection: 4,
        weekStart: 1, weekEnd: 16, color: colors[7], credit: 5,
        remark: '公共必修课'
      },
      {
        id: 'c009', name: '思想政治课', teacher: '郑老师', classroom: '教2-402',
        dayOfWeek: 5, startSection: 1, endSection: 2,
        weekStart: 1, weekEnd: 16, color: colors[0], credit: 3,
        remark: '公共必修课'
      },
      {
        id: 'c010', name: 'HarmonyOS应用开发', teacher: '孙教授', classroom: '实验楼-302',
        dayOfWeek: 5, startSection: 7, endSection: 8,
        weekStart: 3, weekEnd: 18, color: colors[1], credit: 2,
        remark: '专业选修课，上机实践'
      },
      {
        id: 'c011', name: '体育', teacher: '钱老师', classroom: '体育馆',
        dayOfWeek: 3, startSection: 9, endSection: 10,
        weekStart: 1, weekEnd: 16, color: colors[2], credit: 1,
        remark: '公共必修课，篮球班'
      },
      {
        id: 'c012', name: '人工智能导论', teacher: '冯教授', classroom: '教3-301',
        dayOfWeek: 2, startSection: 9, endSection: 10,
        weekStart: 4, weekEnd: 15, color: colors[3], credit: 2,
        remark: '专业选修课'
      }
    ];
  }
}
