import { Course } from '../../model/Course';
import { ColorConstants } from '../../constant/ColorConstants';
import { DateUtil } from '../../utils/DateUtil';
import { BackButton } from '../../components/common/BackButton';

@Entry
@Component
export struct CourseDetailPage {
  @State course: Course | null = null;

  aboutToAppear(): void {
    // 接收参数
  }

  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor(ColorConstants.TEXT_SECONDARY)
        .width(80)
      Text(value)
        .fontSize(14)
        .fontColor(ColorConstants.TEXT_PRIMARY)
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        BackButton({ style: 'text' })
        Text('课程详情')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(ColorConstants.TEXT_PRIMARY)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('编辑')
          .fontSize(16)
          .fontColor(ColorConstants.PRIMARY)
          .width(80)
          .textAlign(TextAlign.End)
      }
      .width('100%')
      .height(50)
      .padding({ left: 16, right: 16 })
      .backgroundColor(ColorConstants.BG_CARD)

      if (this.course) {
        Scroll() {
          Column() {
            // 课程名称卡片
            Column() {
              Text(this.course.name)
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text(this.course.teacher)
                .fontSize(14)
                .fontColor('#FFFFFFCC')
                .margin({ top: 8 })
            }
            .width('100%')
            .padding(24)
            .backgroundColor(this.course.color)
            .borderRadius(12)
            .margin({ bottom: 16 })

            // 详细信息
            Column() {
              this.InfoRow('上课时间', DateUtil.dayOfWeekChinese(this.course.dayOfWeek) +
                ' 第' + this.course.startSection + '-' + this.course.endSection + '节')
              Divider().color(ColorConstants.DIVIDER)
              this.InfoRow('上课教室', this.course.classroom)
              Divider().color(ColorConstants.DIVIDER)
              this.InfoRow('周次', '第' + this.course.weekStart + '-' + this.course.weekEnd + '周')
              Divider().color(ColorConstants.DIVIDER)
              this.InfoRow('学分', this.course.credit + ' 学分')
              if (this.course.remark) {
                Divider().color(ColorConstants.DIVIDER)
                this.InfoRow('备注', this.course.remark)
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
            .backgroundColor(ColorConstants.BG_CARD)
            .borderRadius(12)
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }
}
