import { ScheduleViewModel } from '../../viewmodel/ScheduleViewModel';
import { WeekViewHeader } from '../../components/schedule/WeekViewHeader';
import { TimeSideBar } from '../../components/schedule/TimeSideBar';
import { CourseGridItem } from '../../components/schedule/CourseGridItem';
import { Course } from '../../model/Course';
import { ColorConstants } from '../../constant/ColorConstants';
import { CommonUtil } from '../../utils/CommonUtil';
import { DateUtil } from '../../utils/DateUtil';
import { BackButton } from '../../components/common/BackButton';
import router from '@ohos.router';

// 路由参数接口
interface RouterParams {
  showBack?: boolean;
}

@Entry
@Component
export struct SchedulePage {
  @State viewModel: ScheduleViewModel = new ScheduleViewModel();
  // 响应式周次和选中天（@State 观察不到 viewModel 内部属性变化，需提升为组件状态）
  @State currentWeek: number = DateUtil.getCurrentWeek();
  @State selectedDay: number = DateUtil.getCurrentDayOfWeek();
  private sectionHeight: number = 60;
  private totalSections: number = 12;

  // 今日星期几
  private todayOfWeek: number = DateUtil.getCurrentDayOfWeek();

  // 是否显示返回按钮（从主页跳转时显示）
  @State showBackButton: boolean = false;

  // 课程详情底部弹窗
  @State showCourseDetail: boolean = false;
  @State selectedCourse: Course | null = null;

  // 删除确认弹窗
  @State showDeleteDialog: boolean = false;
  @State courseToDelete: Course | null = null;

  // 添加按钮缩放
  @State addButtonScale: number = 1;

  // 课程表滑动偏移量（用于滑动切换周的过渡动画）
  @State gridTranslateX: number = 0;
  @State gridOpacity: number = 1;

  // 回到本周按钮显示状态
  @State showBackToWeek: boolean = false;

  aboutToAppear(): void {
    // 获取路由参数，判断是否显示返回按钮
    const params = router.getParams() as RouterParams;
    if (params && params.showBack) {
      this.showBackButton = true;
    }
    
    this.viewModel.loadCourses();
    this.updateBackToWeekVisibility();
  }

  /**
   * 更新回到本周按钮的显示状态（纯渐显效果）
   */
  private updateBackToWeekVisibility(): void {
    const shouldShow = this.currentWeek !== DateUtil.getCurrentWeek();
    this.showBackToWeek = shouldShow;
  }

  /**
   * 切换到上一周（带动画）
   */
  private goToPrevWeek(): void {
    if (this.currentWeek <= 1) return;
    // 先向右滑出
    animateTo({ duration: 180, curve: Curve.EaseIn }, () => {
      this.gridTranslateX = 80;
      this.gridOpacity = 0.3;
    });
    setTimeout(() => {
      this.viewModel.prevWeek();
      this.currentWeek = this.viewModel.currentWeek;
      this.gridTranslateX = -80;
      animateTo({ duration: 250, curve: Curve.EaseOut }, () => {
        this.gridTranslateX = 0;
        this.gridOpacity = 1;
      });
      this.updateBackToWeekVisibility();
    }, 180);
  }

  /**
   * 切换到下一周（带动画）
   */
  private goToNextWeek(): void {
    if (this.currentWeek >= this.viewModel.totalWeeks) return;
    // 先向左滑出
    animateTo({ duration: 180, curve: Curve.EaseIn }, () => {
      this.gridTranslateX = -80;
      this.gridOpacity = 0.3;
    });
    setTimeout(() => {
      this.viewModel.nextWeek();
      this.currentWeek = this.viewModel.currentWeek;
      this.gridTranslateX = 80;
      animateTo({ duration: 250, curve: Curve.EaseOut }, () => {
        this.gridTranslateX = 0;
        this.gridOpacity = 1;
      });
      this.updateBackToWeekVisibility();
    }, 180);
  }

  /**
   * 处理左右滑动手势
   */
  private handleSwipe(dx: number): void {
    if (Math.abs(dx) < 60) return; // 滑动距离阈值
    if (dx < 0) {
      // 向左滑 -> 下一周
      this.goToNextWeek();
    } else {
      // 向右滑 -> 上一周
      this.goToPrevWeek();
    }
  }

  /**
   * 点击课程卡片 - 弹出详情
   */
  private onCourseClick(course: Course): void {
    this.selectedCourse = course;
    this.showCourseDetail = true;
  }

  /**
   * 长按课程卡片 - 弹出删除确认
   */
  private onCourseLongClick(course: Course): void {
    this.courseToDelete = course;
    this.showDeleteDialog = true;
  }

  /**
   * 确认删除课程
   */
  private async confirmDeleteCourse(): Promise<void> {
    if (this.courseToDelete) {
      const courseName = this.courseToDelete.name;
      const success = await this.viewModel.deleteCourse(this.courseToDelete.id);
      CommonUtil.showToast(success ? '已删除 ' + courseName : '删除失败');
    }
    this.showDeleteDialog = false;
    this.courseToDelete = null;
  }

  /**
   * 回到本周
   */
  private goToCurrentWeek(): void {
    const targetWeek = DateUtil.getCurrentWeek();
    if (this.currentWeek === targetWeek) return;

    animateTo({ duration: 200, curve: Curve.EaseIn }, () => {
      this.gridOpacity = 0.2;
    });
    setTimeout(() => {
      this.viewModel.setCurrentWeek(targetWeek);
      this.viewModel.setSelectedDay(this.todayOfWeek);
      this.currentWeek = targetWeek;
      this.selectedDay = this.todayOfWeek;
      animateTo({ duration: 250, curve: Curve.EaseOut }, () => {
        this.gridOpacity = 1;
      });
      this.updateBackToWeekVisibility();
    }, 200);
  }

  /**
   * 添加按钮按下效果
   */
  private handleAddButtonPress(pressed: boolean): void {
    animateTo({ duration: pressed ? 100 : 150, curve: Curve.EaseInOut }, () => {
      this.addButtonScale = pressed ? 0.92 : 1;
    });
  }

  @Builder
  DayColumn(day: number) {
    Stack({ alignContent: Alignment.TopStart }) {
      // 背景网格层（12节次分隔线）
      Column() {
        ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], (section: number) => {
          Column()
            .width('100%')
            .height(this.sectionHeight)
            .border({
              width: { bottom: 0.5 },
              color: ColorConstants.DIVIDER
            })
        }, (section: number) => section.toString())
      }
      .width('100%')

      // 课程卡片层（绝对定位，按节次起始位置放置）
      ForEach(this.viewModel.getCoursesByDay(day), (course: Course) => {
        CourseGridItem({
          course: course,
          sectionHeight: this.sectionHeight,
          onCourseClick: (c: Course) => {
            this.onCourseClick(c);
          },
          onCourseLongClick: (c: Course) => {
            this.onCourseLongClick(c);
          }
        })
        .position({
          x: '4%',
          y: (course.startSection - 1) * this.sectionHeight + 3
        })
      }, (course: Course) => course.id)

      // 选中天的空状态提示（仅选中天且无课时显示）
      if (this.selectedDay === day &&
          this.viewModel.getCoursesByDay(day).length === 0) {
        Text('无课')
          .fontSize(11)
          .fontColor(ColorConstants.TEXT_TERTIARY)
          .position({ x: '50%', y: 20 })
          .translate({ x: '-50%' })
      }
    }
    .width('14.28%')
    .height(this.sectionHeight * this.totalSections)
    .clip(true)
  }

  @Builder
  CourseDetailSheet() {
    Column() {
      // 顶部指示条
      Row() {
        Column()
          .width(36)
          .height(5)
          .borderRadius(2.5)
          .backgroundColor(ColorConstants.TEXT_QUATERNARY)
      }
      .width('100%')
      .padding({ top: 10, bottom: 8 })
      .justifyContent(FlexAlign.Center)

      if (this.selectedCourse) {
        // 课程名
        Text(this.selectedCourse.name)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(ColorConstants.TEXT_PRIMARY)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .padding({ left: 20, right: 20, top: 8, bottom: 4 })

        // 课程颜色标识条
        Row()
          .width(40)
          .height(4)
          .borderRadius(2)
          .backgroundColor(this.selectedCourse.color)
          .margin({ left: 20, top: 4, bottom: 16 })

        // 详情列表 - iOS 分组列表风格
        Column() {
          this.DetailRow('教师', this.selectedCourse.teacher || '未设置')
          this.DetailRow('教室', this.selectedCourse.classroom || '未设置')
          this.DetailRow('节次', `第 ${this.selectedCourse.startSection}-${this.selectedCourse.endSection} 节`)
          this.DetailRow('周次', `第 ${this.selectedCourse.weekStart}-${this.selectedCourse.weekEnd} 周`, true)
          if (this.selectedCourse.credit && this.selectedCourse.credit > 0) {
            this.DetailRow('学分', `${this.selectedCourse.credit} 学分`, true)
          }
          if (this.selectedCourse.remark && this.selectedCourse.remark.length > 0) {
            this.DetailRow('备注', this.selectedCourse.remark, true)
          }
        }
        .width('100%')
        .backgroundColor(ColorConstants.BG_CARD)
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 4 })
      }

      // 关闭按钮
      Text('关闭')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(ColorConstants.IOS_BLUE)
        .width('100%')
        .height(50)
        .textAlign(TextAlign.Center)
        .backgroundColor(ColorConstants.BG_CARD)
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 16, bottom: 8 })
        .onClick(() => {
          this.showCourseDetail = false;
          this.selectedCourse = null;
        })
    }
    .width('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
    .borderRadius({ topLeft: 14, topRight: 14 })
  }

  @Builder
  DetailRow(label: string, value: string, isLast: boolean = false) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor(ColorConstants.TEXT_SECONDARY)
        .layoutWeight(1)

      Text(value)
        .fontSize(16)
        .fontColor(ColorConstants.TEXT_PRIMARY)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.End)
        .layoutWeight(2)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .border({
      width: { bottom: isLast ? 0 : 0.5 },
      color: ColorConstants.DIVIDER_OPAQUE
    })
  }

  build() {
    Stack() {
      Column() {
        // iOS 大标题导航栏
        Row() {
          // 返回按钮（根据参数决定是否显示）
          if (this.showBackButton) {
            BackButton()
          } else {
            Blank()
              .width(44)
          }

          Text('课程表')
            .fontSize(34)
            .fontWeight(FontWeight.Bold)
            .fontColor(ColorConstants.TEXT_PRIMARY)
            .layoutWeight(1)

          // iOS 风格添加按钮 - 胶囊形 + 缩放反馈
          Row() {
            Text('+')
              .fontSize(18)
              .fontColor(ColorConstants.IOS_BLUE)
              .fontWeight(FontWeight.Medium)
            Text('添加')
              .fontSize(15)
              .fontColor(ColorConstants.IOS_BLUE)
              .fontWeight(FontWeight.Medium)
          }
          .padding({ left: 12, right: 14, top: 6, bottom: 6 })
          .backgroundColor(ColorConstants.PRIMARY_LIGHT)
          .borderRadius(18)
          .scale({ x: this.addButtonScale, y: this.addButtonScale })
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.handleAddButtonPress(true);
            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
              this.handleAddButtonPress(false);
            }
          })
          .onClick(() => {
            router.pushUrl({ url: 'pages/schedule/AddCoursePage' });
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 12, bottom: 8 })
        .backgroundColor(ColorConstants.BG_PAGE)

        // 周视图头部 - iOS Segmented Control 风格
        WeekViewHeader({
          currentWeek: this.currentWeek,
          selectedDay: this.selectedDay,
          todayOfWeek: this.todayOfWeek,
          onPrevWeek: () => {
            this.goToPrevWeek();
          },
          onNextWeek: () => {
            this.goToNextWeek();
          },
          onSelectDay: (day: number) => {
            this.viewModel.setSelectedDay(day);
            this.selectedDay = day;
          }
        })
        .margin({ top: 4 })

        // 课程表主体 - iOS卡片风格 + 左右滑动切换周
        Scroll() {
          Row() {
            // 时间栏（随垂直滚动联动）
            TimeSideBar({
              totalSections: this.totalSections,
              sectionHeight: this.sectionHeight
            })

            // 7天课程列
            Row() {
              ForEach([1, 2, 3, 4, 5, 6, 7], (day: number) => {
                this.DayColumn(day)
              }, (day: number) => day.toString())
            }
            .layoutWeight(1)
            .translate({ x: this.gridTranslateX })
            .opacity(this.gridOpacity)
          }
          .width('100%')
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(ColorConstants.BG_CARD)
        .borderRadius(16)
        .margin({ left: 16, right: 16, top: 12 })
        .gesture(
          PanGesture({ direction: PanDirection.Horizontal, distance: 30 })
            .onActionEnd((event: GestureEvent) => {
              this.handleSwipe(event.offsetX);
            })
        )
        .shadow({
          radius: 10,
          color: 'rgba(0, 0, 0, 0.04)',
          offsetX: 0,
          offsetY: 2
        })

      }
      .width('100%')
      .height('100%')
      .backgroundColor(ColorConstants.BG_PAGE)

      // 悬浮回到本周按钮（非本周时显示，渐显动画）
      if (this.showBackToWeek) {
        Text('回到本周')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(ColorConstants.IOS_BLUE)
          .padding({ left: 20, right: 20, top: 12, bottom: 12 })
          .backgroundColor('rgba(255, 255, 255, 0.6)')
          .borderRadius(24)
          .shadow({
            radius: 16,
            color: 'rgba(0, 0, 0, 0.08)',
            offsetX: 0,
            offsetY: 4
          })
          .position({ x: '50%', y: '100%' })
          .translate({ x: '-50%', y: -72 })
          .onClick(() => {
            this.goToCurrentWeek();
          })
          .transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseOut }))
      }

      // 课程详情底部弹窗 - iOS Action Sheet 风格
      if (this.showCourseDetail) {
        // 半透明遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.4)')
          .onClick(() => {
            this.showCourseDetail = false;
            this.selectedCourse = null;
          })
          .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))

        // 底部弹出内容 - 使用 bindSheet 样式定位到底部
        Column() {
          this.CourseDetailSheet()
        }
        .width('100%')
        .position({ x: 0, y: '100%' })
        .translate({ y: '-100%' })
        .transition(TransitionEffect.translate({ y: '100%' }).animation({ duration: 300, curve: Curve.EaseOut }))
      }

      // 删除确认弹窗 - iOS 风格 Alert
      if (this.showDeleteDialog) {
        // 半透明遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.4)')
          .onClick(() => {
            this.showDeleteDialog = false;
            this.courseToDelete = null;
          })
          .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))

        // iOS 风格 Alert 对话框
        Column() {
          Text('删除课程')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(ColorConstants.TEXT_PRIMARY)
            .margin({ top: 16, bottom: 6 })

          Text(`确定要删除"${this.courseToDelete?.name || ''}"吗？`)
            .fontSize(13)
            .fontColor(ColorConstants.TEXT_SECONDARY)
            .textAlign(TextAlign.Center)
            .padding({ left: 16, right: 16, bottom: 16 })

          // 分隔线
          Row()
            .width('100%')
            .height(0.5)
            .backgroundColor(ColorConstants.DIVIDER_OPAQUE)

          // 按钮行
          Row() {
            Text('取消')
              .fontSize(17)
              .fontColor(ColorConstants.IOS_BLUE)
              .layoutWeight(1)
              .height(44)
              .textAlign(TextAlign.Center)
              .onClick(() => {
                this.showDeleteDialog = false;
                this.courseToDelete = null;
              })

            // 垂直分隔线
            Column()
              .width(0.5)
              .height('100%')
              .backgroundColor(ColorConstants.DIVIDER_OPAQUE)

            Text('删除')
              .fontSize(17)
              .fontWeight(FontWeight.Medium)
              .fontColor(ColorConstants.IOS_RED)
              .layoutWeight(1)
              .height(44)
              .textAlign(TextAlign.Center)
              .onClick(() => {
                this.confirmDeleteCourse();
              })
          }
          .width('100%')
        }
        .width(270)
        .backgroundColor(ColorConstants.BG_CARD)
        .borderRadius(14)
        .transition(TransitionEffect.OPACITY.animation({ duration: 200 })
          .combine(TransitionEffect.scale({ x: 1.1, y: 1.1 }).animation({ duration: 200 })))
      }
    }
    .width('100%')
    .height('100%')
  }
}
