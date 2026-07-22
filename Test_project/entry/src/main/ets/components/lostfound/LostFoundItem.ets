import { LostFoundItem as LFItem } from '../../model/LostFound';
import { ColorConstants } from '../../constant/ColorConstants';

@Component
export struct LostFoundItemCard {
  @Prop item: LFItem = {
    id: '',
    type: 'lost',
    title: '',
    description: '',
    location: '',
    time: '',
    contact: '',
    category: '',
    status: 'active',
    publishTime: ''
  };
  isFirst?: boolean = false;
  isLast?: boolean = false;
  onCardClick?: (item: LFItem) => void;

  @State isPressed: boolean = false;

  build() {
    Row() {
      // 左侧图片/图标 - iOS 圆角 10px
      Column() {
        Text(this.item.type === 'lost' ? '🔍' : '📦')
          .fontSize(26)
      }
      .width(56)
      .height(56)
      .backgroundColor(this.item.type === 'lost'
        ? 'rgba(255, 149, 0, 0.12)'
        : 'rgba(52, 199, 89, 0.12)')
      .borderRadius(10)
      .justifyContent(FlexAlign.Center)

      // 中间内容区域
      Column() {
        Row() {
          // 标题
          Text(this.item.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(ColorConstants.TEXT_PRIMARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          // 状态胶囊标签
          Text(this.item.status === 'completed' ? '已完成' : (this.item.type === 'lost' ? '寻物' : '招领'))
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .backgroundColor(
              this.item.status === 'completed'
                ? ColorConstants.TEXT_TERTIARY
                : (this.item.type === 'lost' ? ColorConstants.IOS_ORANGE : ColorConstants.IOS_GREEN)
            )
            .borderRadius(10)
        }
        .width('100%')

        // 地点
        Text('📍 ' + this.item.location)
          .fontSize(13)
          .fontColor(ColorConstants.TEXT_SECONDARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ top: 4 })

        // 时间 + 分类
        Row() {
          Text(this.item.publishTime.substring(5, 16))
            .fontSize(12)
            .fontColor(ColorConstants.TEXT_TERTIARY)

          Text('·')
            .fontSize(12)
            .fontColor(ColorConstants.TEXT_TERTIARY)
            .margin({ left: 6, right: 6 })

          Text(this.item.category)
            .fontSize(12)
            .fontColor(ColorConstants.TEXT_TERTIARY)
        }
        .width('100%')
        .margin({ top: 3 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12, right: 8 })

      // 右侧箭头 - iOS chevron 风格
      Column() {
        Text('>')
          .fontSize(18)
          .fontColor(ColorConstants.TEXT_TERTIARY)
          .fontWeight(FontWeight.Lighter)
      }
      .margin({ right: 4 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(ColorConstants.BG_CARD)
    // 点击反馈动画：缩放 + 透明度变化
    .scale({ x: this.isPressed ? 0.97 : 1.0, y: this.isPressed ? 0.97 : 1.0 })
    .opacity(this.isPressed ? 0.7 : 1.0)
    .animation({
      duration: 150,
      curve: Curve.EaseInOut,
      playMode: PlayMode.Normal
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false;
      }
    })
    .onClick(() => {
      this.onCardClick?.(this.item);
    })
  }
}
