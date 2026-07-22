package com.campus.life.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.life.common.BusinessException;
import com.campus.life.common.ResultCode;
import com.campus.life.dto.CourseRequest;
import com.campus.life.entity.Course;
import com.campus.life.mapper.CourseMapper;
import com.campus.life.service.CourseService;
import com.campus.life.utils.UserContext;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 课程服务实现
 */
@Slf4j
@Service
public class CourseServiceImpl extends ServiceImpl<CourseMapper, Course> implements CourseService {

    @Override
    public List<Course> listCurrentUserCourses() {
        Long userId = UserContext.getUserId();
        return list(new LambdaQueryWrapper<Course>()
                .eq(Course::getUserId, userId)
                .orderByAsc(Course::getDayOfWeek)
                .orderByAsc(Course::getStartSection));
    }

    @Override
    public List<Course> listCoursesByDay(Integer dayOfWeek, Integer week) {
        Long userId = UserContext.getUserId();
        LambdaQueryWrapper<Course> wrapper = new LambdaQueryWrapper<Course>()
                .eq(Course::getUserId, userId)
                .eq(Course::getDayOfWeek, dayOfWeek)
                .le(Course::getWeekStart, week)
                .ge(Course::getWeekEnd, week)
                .orderByAsc(Course::getStartSection);
        return list(wrapper);
    }

    @Override
    public List<Course> listCoursesByWeek(Integer week) {
        Long userId = UserContext.getUserId();
        return list(new LambdaQueryWrapper<Course>()
                .eq(Course::getUserId, userId)
                .le(Course::getWeekStart, week)
                .ge(Course::getWeekEnd, week)
                .orderByAsc(Course::getDayOfWeek)
                .orderByAsc(Course::getStartSection));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Course addCourse(CourseRequest request) {
        validateSectionRange(request);
        Course course = new Course();
        BeanUtils.copyProperties(request, course);
        course.setUserId(UserContext.getUserId());
        save(course);
        log.info("新增课程 | userId={} | courseId={} | name={}", course.getUserId(), course.getId(), course.getName());
        return course;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Course updateCourse(Long id, CourseRequest request) {
        Course course = getOwnedCourse(id);
        validateSectionRange(request);
        BeanUtils.copyProperties(request, course);
        updateById(course);
        return course;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteCourse(Long id) {
        Course course = getOwnedCourse(id);
        removeById(course.getId());
        log.info("删除课程 | userId={} | courseId={}", UserContext.getUserId(), id);
    }

    @Override
    public Course getCourseDetail(Long id) {
        return getOwnedCourse(id);
    }

    /**
     * 校验节次范围
     */
    private void validateSectionRange(CourseRequest request) {
        if (request.getStartSection() > request.getEndSection()) {
            throw new BusinessException("开始节次不能大于结束节次");
        }
        if (request.getWeekStart() > request.getWeekEnd()) {
            throw new BusinessException("起始周不能大于结束周");
        }
    }

    /**
     * 获取当前用户拥有的课程
     */
    private Course getOwnedCourse(Long id) {
        Course course = getById(id);
        if (course == null) {
            throw new BusinessException(ResultCode.COURSE_NOT_EXIST);
        }
        if (!course.getUserId().equals(UserContext.getUserId())) {
            throw new BusinessException(ResultCode.FORBIDDEN, "无权操作此课程");
        }
        return course;
    }
}
