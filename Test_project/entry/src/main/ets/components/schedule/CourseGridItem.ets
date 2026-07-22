import { Course } from '../../model/Course';

@Component
export struct CourseGridItem {
  @Prop course: Course = {
    id: '',
    name: '',
    teacher: '',
    classroom: '',
    dayOfWeek: 1,
    startSection: 1,
    endSection: 1,
    weekStart: 1,
    weekEnd: 1,
    color: '#007AFF',
    credit: 0
  };
  sectionHeight: number = 60;
  onCourseClick?: (course: Course) => void;
  onCourseLongClick?: (course: Course) => void;

  @State cardScale: number = 1;
  @State isPressed: boolean = false;

  /**
   * 处理点击缩放反馈
   */
  private handlePressIn(): void {
    animateTo({ duration: 120, curve: Curve.EaseIn }, () => {
      this.cardScale = 0.92;
      this.isPressed = true;
    });
  }

  private handlePressOut(): void {
    animateTo({ duration: 200, curve: Curve.EaseOut }, () => {
      this.cardScale = 1;
      this.isPressed = false;
    });
  }

  build() {
    Column() {
      Text(this.course.name)
        .fontSize(11)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Medium)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .textAlign(TextAlign.Center)
        .lineHeight(14)

      Text(this.course.classroom)
        .fontSize(10)
        .fontColor('rgba(255, 255, 255, 0.85)')
        .margin({ top: 4 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('92%')
    .height((this.course.endSection - this.course.startSection + 1) * this.sectionHeight - 6)
    .padding({ left: 6, right: 6, top: 8, bottom: 8 })
    .backgroundColor(this.course.color)
    .borderRadius(9)
    .justifyContent(FlexAlign.Center)
    .scale({ x: this.cardScale, y: this.cardScale })
    .shadow({
      radius: this.isPressed ? 2 : 4,
      color: 'rgba(0, 0, 0, 0.12)',
      offsetX: 0,
      offsetY: this.isPressed ? 0.5 : 1
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.handlePressIn();
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.handlePressOut();
      }
    })
    .onClick(() => {
      this.onCourseClick?.(this.course);
    })
    .gesture(
      LongPressGesture({ repeat: false, duration: 500 })
        .onAction(() => {
          // 长按时恢复缩放状态
          this.cardScale = 1;
          this.isPressed = false;
          this.onCourseLongClick?.(this.course);
        })
    )
  }
}
