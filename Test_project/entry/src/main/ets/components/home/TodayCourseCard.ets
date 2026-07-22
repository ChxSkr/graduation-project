import { Course } from '../../model/Course';
import { ColorConstants } from '../../constant/ColorConstants';
import { DateUtil } from '../../utils/DateUtil';

// 时间轴课程项组件
@Component
export struct TimelineCourseItem {
  course!: Course;
  index!: number;
  isLast: boolean = false;
  isOngoing: boolean = false;
  isPast: boolean = false;
  onCourseClick?: (course: Course) => void;

  // 计算课程时长（节数）
  private getDuration(): number {
    return this.course.endSection - this.course.startSection + 1;
  }

  // 获取课程开始时间
  private getStartTime(): string {
    return DateUtil.getSectionTime(this.course.startSection);
  }

  // 获取课程结束时间
  private getEndTime(): string {
    return DateUtil.getSectionTime(this.course.endSection + 1) || '';
  }

  // 脉冲动画状态
  @State pulseScale: number = 1;
  @State pulseOpacity: number = 0.6;

  aboutToAppear() {
    if (this.isOngoing) {
      this.startPulseAnimation();
    }
  }

  private startPulseAnimation() {
    animateTo({
      duration: 1500,
      curve: Curve.EaseInOut,
      iterations: -1,
      playMode: PlayMode.Alternate
    }, () => {
      this.pulseScale = 1.8;
      this.pulseOpacity = 0;
    });
  }

  @Builder
  timelineDot() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.isOngoing) {
        // 进行中：蓝色脉冲光晕
        Circle()
          .width(16)
          .height(16)
          .fill(ColorConstants.PRIMARY)
          .opacity(this.pulseOpacity)
          .scale({ x: this.pulseScale, y: this.pulseScale })

        // 主圆点
        Circle()
          .width(12)
          .height(12)
          .fill(ColorConstants.PRIMARY)
          .shadow({
            radius: 6,
            color: ColorConstants.PRIMARY + '80',
            offsetX: 0,
            offsetY: 0
          })

        // 内圈白色高光
        Circle()
          .width(4)
          .height(4)
          .fill(Color.White)
      } else if (this.isPast) {
        // 已结束：灰色小点
        Circle()
          .width(8)
          .height(8)
          .fill(ColorConstants.TEXT_TERTIARY)
      } else {
        // 未开始：蓝色描边空心圆
        Circle()
          .width(10)
          .height(10)
          .fill(Color.White)
          .stroke(this.course.color || ColorConstants.PRIMARY)
          .strokeWidth(2)
      }
    }
    .width(20)
    .height(20)
  }

  @Builder
  dashedDivider() {
    Column() {
      // 虚线分隔（使用多个小圆点模拟）
      ForEach([0, 1, 2, 3, 4, 5, 6, 7], (item: number) => {
        Circle()
          .width(2)
          .height(2)
          .fill(ColorConstants.DIVIDER)
          .margin({ top: 2, bottom: 2 })
      }, (item: number) => item.toString())
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Row() {
      // 左侧时间 + 时间轴
      Column() {
        // 时间
        Text(this.getStartTime())
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isPast ? ColorConstants.TEXT_TERTIARY : ColorConstants.TEXT_PRIMARY)

        Text(this.getDuration() + '节')
          .fontSize(10.5)
          .fontColor(ColorConstants.TEXT_TERTIARY)
          .margin({ top: 2 })
      }
      .width(52)
      .alignItems(HorizontalAlign.End)
      .padding({ right: 10, top: 2 })

      // 时间轴（竖线 + 圆点）
      Column() {
        // 圆点
        this.timelineDot()

        // 竖线（不是最后一个才显示）
        if (!this.isLast) {
          Column()
            .width(1.5)
            .layoutWeight(1)
            .backgroundColor(this.isPast ? ColorConstants.DIVIDER : ColorConstants.DIVIDER)
            .margin({ top: 4, bottom: 4 })
            .opacity(0.6)
        }
      }
      .width(20)
      .alignItems(HorizontalAlign.Center)

      // 右侧课程信息
      Column({ space: 4 }) {
        // 课程名 + 进行中标签
        Row() {
          Text(this.course.name)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.isPast ? ColorConstants.TEXT_TERTIARY : ColorConstants.TEXT_PRIMARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          if (this.isOngoing) {
            Text('进行中')
              .fontSize(10)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .backgroundColor(ColorConstants.PRIMARY)
              .borderRadius(10)
          }
        }
        .width('100%')

        // 教室 + 教师
        Row() {
          Text(this.course.classroom)
            .fontSize(12)
            .fontColor(this.isPast ? ColorConstants.TEXT_TERTIARY : ColorConstants.TEXT_SECONDARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(' · ' + this.course.teacher)
            .fontSize(12)
            .fontColor(this.isPast ? ColorConstants.TEXT_TERTIARY : ColorConstants.TEXT_SECONDARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')

        // 节次
        Text('第' + this.course.startSection + '-' + this.course.endSection + '节')
          .fontSize(11)
          .fontColor(ColorConstants.TEXT_TERTIARY)
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .padding({ left: 10, top: 2, bottom: 2 })
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
    .opacity(this.isPast ? 0.7 : 1)
    .onClick(() => {
      this.onCourseClick?.(this.course);
    })
  }
}

@Component
export struct TodayCourseCard {
  courses: Course[] = [];
  onCourseClick?: (course: Course) => void;
  onMoreClick?: () => void;

  // 计算今日进度（已结束课程数 / 总课程数）
  private getProgress(): number {
    if (this.courses.length === 0) return 0;
    // 简单模拟：第1节课进行中 = 进度约 20%，第2节 = 45%，最后一节 = 85%
    // 实际项目中应根据当前时间计算
    const total = this.courses.length;
    const ongoingIndex = this.getOngoingIndex();
    if (ongoingIndex < 0) {
      // 都还没开始
      return 0;
    }
    return Math.min(95, Math.round((ongoingIndex + 0.5) / total * 100));
  }

  // 获取进行中的课程索引（模拟：第一节课默认为进行中）
  private getOngoingIndex(): number {
    if (this.courses.length === 0) return -1;
    // 简单逻辑：默认第1节为进行中（实际应根据当前时间判断）
    return 0;
  }

  // 获取剩余课程数
  private getRemainingCount(): number {
    const ongoingIndex = this.getOngoingIndex();
    if (ongoingIndex < 0) return this.courses.length;
    return Math.max(0, this.courses.length - ongoingIndex - 1);
  }

  // 获取下一节课
  private getNextCourse(): Course | null {
    const ongoingIndex = this.getOngoingIndex();
    if (ongoingIndex < 0 && this.courses.length > 0) {
      return this.courses[0];
    }
    if (ongoingIndex >= 0 && ongoingIndex < this.courses.length - 1) {
      return this.courses[ongoingIndex + 1];
    }
    return null;
  }

  @Builder
  progressBar() {
    Column({ space: 10 }) {
      // 进度文字行
      Row() {
        Text('今日进度 ' + this.getProgress() + '%')
          .fontSize(12.5)
          .fontColor(ColorConstants.TEXT_SECONDARY)
          .layoutWeight(1)

        Text('还有 ' + this.getRemainingCount() + ' 节课')
          .fontSize(12.5)
          .fontColor(ColorConstants.TEXT_SECONDARY)
      }
      .width('100%')

      // 进度条 + 下一节按钮
      Row() {
        // 进度条背景
        Stack({ alignContent: Alignment.Start }) {
          // 背景轨道
          Column()
            .width('100%')
            .height(6)
            .backgroundColor(ColorConstants.BG_TERTIARY)
            .borderRadius(3)

          // 进度填充
          Column()
            .width(this.getProgress() + '%')
            .height(6)
            .linearGradient({
              direction: GradientDirection.Right,
              colors: [
                [ColorConstants.PRIMARY, 0],
                [ColorConstants.TEAL, 1]
              ]
            })
            .borderRadius(3)
        }
        .layoutWeight(1)
        .margin({ right: 14 })

        // 下一节胶囊按钮
        Row() {
          Text('下一节')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)

          Text('>')
            .fontSize(12)
            .fontColor(Color.White)
            .margin({ left: 2 })
        }
        .padding({ left: 14, right: 14, top: 7, bottom: 7 })
        .linearGradient({
          direction: GradientDirection.Right,
          colors: [
            [ColorConstants.PRIMARY, 0],
            [ColorConstants.TEAL, 1]
          ]
        })
        .borderRadius(16)
        .onClick(() => {
          this.onMoreClick?.();
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding({ top: 14, bottom: 4 })
  }

  @Builder
  emptyState() {
    Column() {
      Row() {
        Column() {
          Text('今天没有课')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(ColorConstants.TEXT_PRIMARY)

          Text('享受美好的闲暇时光 ~')
            .fontSize(13)
            .fontColor(ColorConstants.TEXT_SECONDARY)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 装饰图标
        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(56)
            .height(56)
            .fill(ColorConstants.BG_TERTIARY)

          Text('☕')
            .fontSize(28)
        }
      }
      .width('100%')
      .padding(20)
      .backgroundColor(ColorConstants.BG_PAGE)
      .borderRadius(20)
    }
    .width('100%')
    .margin({ top: 8 })
  }

  build() {
    Column() {
      // 标题行
      Row() {
        Column({ space: 2 }) {
          Text('今日课表')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(ColorConstants.TEXT_PRIMARY)

          Text('今天有 ' + this.courses.length + ' 节课')
            .fontSize(12)
            .fontColor(ColorConstants.TEXT_TERTIARY)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('查看全部')
          .fontSize(13)
          .fontColor(ColorConstants.PRIMARY)
          .onClick(() => {
            this.onMoreClick?.();
          })
      }
      .width('100%')
      .margin({ bottom: 10 })

      if (this.courses.length === 0) {
        // 空状态
        this.emptyState()
      } else {
        // 课程列表（时间轴风格）
        Column() {
          ForEach(
            this.courses.slice(0, 3),
            (course: Course, index: number) => {
              TimelineCourseItem({
                course: course,
                index: index,
                isLast: index === Math.min(this.courses.length, 3) - 1,
                isOngoing: index === this.getOngoingIndex(),
                isPast: this.getOngoingIndex() >= 0 && index < this.getOngoingIndex(),
                onCourseClick: (c: Course) => {
                  this.onCourseClick?.(c);
                }
              })
            },
            (course: Course) => course.id
          )
        }
        .width('100%')
        .margin({ top: 4, bottom: 4 })

        // 底部进度条
        this.progressBar()
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor(ColorConstants.BG_CARD)
    .borderRadius(26)
    .shadow({
      radius: 20,
      color: 'rgba(20, 40, 90, 0.08)',
      offsetX: 0,
      offsetY: 6
    })
    .border({
      width: 0.5,
      color: 'rgba(255, 255, 255, 0.9)'
    })
  }
}
