package com.campus.life.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.life.dto.CourseRequest;
import com.campus.life.entity.Course;

import java.util.List;

/**
 * 课程服务接口
 */
public interface CourseService extends IService<Course> {

    /**
     * 获取当前用户的所有课程
     */
    List<Course> listCurrentUserCourses();

    /**
     * 获取当前用户某周某天的课程
     */
    List<Course> listCoursesByDay(Integer dayOfWeek, Integer week);

    /**
     * 获取当前用户某周的所有课程
     */
    List<Course> listCoursesByWeek(Integer week);

    /**
     * 新增课程
     */
    Course addCourse(CourseRequest request);

    /**
     * 修改课程
     */
    Course updateCourse(Long id, CourseRequest request);

    /**
     * 删除课程
     */
    void deleteCourse(Long id);

    /**
     * 获取课程详情
     */
    Course getCourseDetail(Long id);
}
