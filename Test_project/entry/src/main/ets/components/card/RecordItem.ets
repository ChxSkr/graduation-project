import { ConsumptionRecord } from '../../model/CampusCard';
import { ColorConstants } from '../../constant/ColorConstants';
import { CommonUtil } from '../../utils/CommonUtil';

@Component
export struct RecordItem {
  @Prop record: ConsumptionRecord = {
    id: '',
    amount: 0,
    type: 'consume',
    location: '',
    time: ''
  };

  @Builder
  IconView() {
    Column() {
      Text(this.record.type === 'recharge' ? '+¥' : '¥')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
    }
    .width(36)
    .height(36)
    .borderRadius(10)
    .backgroundColor(this.record.type === 'recharge'
      ? ColorConstants.IOS_GREEN
      : ColorConstants.IOS_BLUE)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Row() {
      // 左侧图标
      this.IconView()

      // 中间信息：标题 + 副标题
      Column() {
        Text(this.record.location)
          .fontSize(16)
          .fontWeight(FontWeight.Regular)
          .fontColor(ColorConstants.TEXT_PRIMARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.record.time)
          .fontSize(13)
          .fontColor(ColorConstants.TEXT_SECONDARY)
          .margin({ top: 3 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      // 右侧金额 + 箭头
      Row() {
        Text((this.record.amount >= 0 ? '+' : '-') + CommonUtil.formatMoney(Math.abs(this.record.amount)))
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.record.amount >= 0
            ? ColorConstants.IOS_GREEN
            : ColorConstants.TEXT_PRIMARY)

        Text('›')
          .fontSize(20)
          .fontColor(ColorConstants.TEXT_TERTIARY)
          .margin({ left: 6 })
      }
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
  }
}
