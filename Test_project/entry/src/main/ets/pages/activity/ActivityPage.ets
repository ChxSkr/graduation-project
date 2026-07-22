import { ColorConstants } from '../../constant/ColorConstants';

/**
 * 校园活动页面（占位）
 * 后续可扩展为活动列表 + 报名 + 详情等完整功能
 */
@Entry
@Component
struct ActivityPage {
  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('校园活动')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(ColorConstants.TEXT_PRIMARY)
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      // 空状态占位
      Column({ space: 16 }) {
        Text('🎉')
          .fontSize(64)

        Text('暂无活动')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(ColorConstants.TEXT_SECONDARY)

        Text('校园活动上线后将在此展示')
          .fontSize(13)
          .fontColor(ColorConstants.TEXT_TERTIARY)
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }
}

export { ActivityPage }
