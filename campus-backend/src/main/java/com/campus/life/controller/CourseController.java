package com.campus.life.controller;

import com.campus.life.common.Result;
import com.campus.life.dto.CourseRequest;
import com.campus.life.entity.Course;
import com.campus.life.service.CourseService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 课程表 Controller
 * 路径前缀：/course
 */
@RestController
@RequestMapping("/course")
@RequiredArgsConstructor
public class CourseController {

    private final CourseService courseService;

    /**
     * 获取当前用户所有课程
     * GET /api/course/list
     */
    @GetMapping("/list")
    public Result<List<Course>> list() {
        return Result.success(courseService.listCurrentUserCourses());
    }

    /**
     * 获取某周某天的课程
     * GET /api/course/listByDay?dayOfWeek=1&week=5
     */
    @GetMapping("/listByDay")
    public Result<List<Course>> listByDay(@RequestParam Integer dayOfWeek,
                                          @RequestParam(required = false, defaultValue = "1") Integer week) {
        return Result.success(courseService.listCoursesByDay(dayOfWeek, week));
    }

    /**
     * 获取某周所有课程
     * GET /api/course/listByWeek?week=5
     */
    @GetMapping("/listByWeek")
    public Result<List<Course>> listByWeek(@RequestParam(required = false, defaultValue = "1") Integer week) {
        return Result.success(courseService.listCoursesByWeek(week));
    }

    /**
     * 获取课程详情
     * GET /api/course/{id}
     */
    @GetMapping("/{id}")
    public Result<Course> detail(@PathVariable Long id) {
        return Result.success(courseService.getCourseDetail(id));
    }

    /**
     * 新增课程
     * POST /api/course
     */
    @PostMapping
    public Result<Course> add(@Valid @RequestBody CourseRequest request) {
        return Result.success(courseService.addCourse(request), "添加成功");
    }

    /**
     * 修改课程
     * PUT /api/course/{id}
     */
    @PutMapping("/{id}")
    public Result<Course> update(@PathVariable Long id, @Valid @RequestBody CourseRequest request) {
        return Result.success(courseService.updateCourse(id, request), "修改成功");
    }

    /**
     * 删除课程
     * DELETE /api/course/{id}
     */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        courseService.deleteCourse(id);
        return Result.success(null, "删除成功");
    }
}
