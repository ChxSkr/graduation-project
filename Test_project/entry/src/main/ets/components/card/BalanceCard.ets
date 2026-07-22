import { CardInfo } from '../../model/CampusCard';
import { ColorConstants } from '../../constant/ColorConstants';
import { CommonUtil } from '../../utils/CommonUtil';

@Component
export struct BalanceCard {
  cardInfo: CardInfo | null = null;

  build() {
    Column() {
      if (this.cardInfo) {
        // 卡片顶部：卡类型标识 + 状态
        Row() {
          Row() {
            Text('💳')
              .fontSize(20)
            Text('校园卡')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .margin({ left: 6 })
          }
          .layoutWeight(1)

          Text(this.cardInfo.status === 'normal' ? '正常' : '已挂失')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .backgroundColor(this.cardInfo.status === 'normal'
              ? 'rgba(52, 199, 89, 0.8)'
              : 'rgba(255, 59, 48, 0.8)')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .borderRadius(10)
        }
        .width('100%')

        // 余额区域
        Column() {
          Text('余额')
            .fontSize(14)
            .fontColor('rgba(255, 255, 255, 0.7)')
            .letterSpacing(0.5)

          Text('¥')
            .fontSize(20)
            .fontWeight(FontWeight.Regular)
            .fontColor('rgba(255, 255, 255, 0.9)')
            .margin({ top: 12 })

          Text(CommonUtil.formatMoney(this.cardInfo.balance))
            .fontSize(40)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .letterSpacing(-0.5)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ top: 24, bottom: 28 })

        // 底部信息：卡号 + 持卡人
        Row() {
          Column() {
            Text('卡号')
              .fontSize(11)
              .fontColor('rgba(255, 255, 255, 0.55)')
            Text(CommonUtil.maskCardNo(this.cardInfo.cardNo))
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('rgba(255, 255, 255, 0.95)')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Column() {
            Text('持卡人')
              .fontSize(11)
              .fontColor('rgba(255, 255, 255, 0.55)')
            Text(this.cardInfo.userName)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('rgba(255, 255, 255, 0.95)')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.End)
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(24)
    .borderRadius(20)
    .linearGradient({
      direction: GradientDirection.LeftTop,
      colors: [
        ['#0A84FF', 0.0],
        [ColorConstants.IOS_BLUE, 0.5],
        ['#0040DD', 1.0]
      ]
    })
    .shadow({
      radius: 16,
      color: 'rgba(0, 122, 255, 0.3)',
      offsetX: 0,
      offsetY: 8
    })
  }
}
