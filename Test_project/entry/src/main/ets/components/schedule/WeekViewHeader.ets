import { ColorConstants } from '../../constant/ColorConstants';
import { DateUtil } from '../../utils/DateUtil';

@Component
export struct WeekViewHeader {
  @Prop @Watch('onWeekChanged') currentWeek: number = 1;
  @Prop selectedDay: number = 1;
  @Prop todayOfWeek: number = 1;
  onPrevWeek?: () => void;
  onNextWeek?: () => void;
  onSelectDay?: (day: number) => void;

  @State weekTextScale: number = 1;
  @State weekTextOpacity: number = 1;
  @State weekDates: Date[] = DateUtil.getWeekDatesByWeek(1);

  private weekDays: string[] = ['一', '二', '三', '四', '五', '六', '日'];

  // 监听 currentWeek 变化，更新日期数组
  onWeekChanged(): void {
    this.weekDates = DateUtil.getWeekDatesByWeek(this.currentWeek);
  }

  /**
   * 触发周切换动画
   */
  animateWeekChange(direction: number): void {
    animateTo({ duration: 150, curve: Curve.EaseIn }, () => {
      this.weekTextScale = 0.85;
      this.weekTextOpacity = 0.4;
    });
    setTimeout(() => {
      animateTo({ duration: 200, curve: Curve.EaseOut }, () => {
        this.weekTextScale = 1;
        this.weekTextOpacity = 1;
      });
    }, 150);
  }

  @Builder
  DayItem(day: number, dateStr: string) {
    Column() {
      // 周几文字
      Text(this.weekDays[day - 1])
        .fontSize(12)
        .fontColor(this.selectedDay === day ? ColorConstants.IOS_BLUE :
          (day === this.todayOfWeek ? ColorConstants.IOS_BLUE : ColorConstants.TEXT_SECONDARY))
        .fontWeight(this.selectedDay === day ? FontWeight.Medium :
          (day === this.todayOfWeek ? FontWeight.Medium : FontWeight.Regular))

      // 日期数字 - 选中时蓝色圆形背景，今日有特殊高亮环
      Text(dateStr)
        .fontSize(16)
        .fontWeight(this.selectedDay === day ? FontWeight.Medium :
          (day === this.todayOfWeek ? FontWeight.Medium : FontWeight.Regular))
        .fontColor(this.selectedDay === day ? '#FFFFFF' :
          (day === this.todayOfWeek ? ColorConstants.IOS_BLUE : ColorConstants.TEXT_PRIMARY))
        .width(32)
        .height(32)
        .textAlign(TextAlign.Center)
        .backgroundColor(this.selectedDay === day ? ColorConstants.IOS_BLUE : ColorConstants.TRANSPARENT)
        .borderRadius(16)
        .margin({ top: 6 })
        .border({
          width: day === this.todayOfWeek && this.selectedDay !== day ? 1.5 : 0,
          color: ColorConstants.IOS_BLUE
        })
    }
    .width('14.28%')
    .height(68)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.onSelectDay?.(day);
    })
  }

  @Builder
  SegmentedControl() {
    // iOS Segmented Control 风格 - 圆角胶囊形分段控件
    Row() {
      // 左箭头 - 上一周
      Text('‹')
        .fontSize(24)
        .fontColor(this.currentWeek > 1 ? ColorConstants.IOS_BLUE : ColorConstants.TEXT_TERTIARY)
        .width(36)
        .height(36)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          if (this.currentWeek > 1) {
            this.animateWeekChange(-1);
            this.onPrevWeek?.();
          }
        })

      // 中间分段控件 - 周数醒目显示
      Row() {
        Text(`第${this.currentWeek}周`)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(ColorConstants.TEXT_PRIMARY)
          .padding({ left: 16, right: 16, top: 7, bottom: 7 })
          .backgroundColor(ColorConstants.BG_CARD)
          .borderRadius(9)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .scale({ x: this.weekTextScale, y: this.weekTextScale })
          .opacity(this.weekTextOpacity)
      }
      .layoutWeight(1)
      .padding(2)
      .backgroundColor(ColorConstants.BG_SECONDARY)
      .borderRadius(11)

      // 右箭头 - 下一周
      Text('›')
        .fontSize(24)
        .fontColor(this.currentWeek < 20 ? ColorConstants.IOS_BLUE : ColorConstants.TEXT_TERTIARY)
        .width(36)
        .height(36)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          if (this.currentWeek < 20) {
            this.animateWeekChange(1);
            this.onNextWeek?.();
          }
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  build() {
    Column() {
      // iOS Segmented Control 风格周切换
      this.SegmentedControl()

      // 星期头部 - 白底圆角卡片风格
      Row() {
        // 左侧时间栏占位（与课程表对齐）
        Column()
          .width(40)

        // 星期几 + 日期
        Row() {
          ForEach(this.weekDays, (_: string, index: number) => {
            this.DayItem(index + 1, this.weekDates[index].getDate().toString())
          }, (_: string, index: number) => `${this.currentWeek}_${index}_${this.weekDates[index].getDate()}`)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    }
    .width('100%')
    .padding({ top: 8, bottom: 4 })
    .backgroundColor(ColorConstants.BG_PAGE)
  }
}
