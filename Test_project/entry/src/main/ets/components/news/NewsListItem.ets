import { NewsItem } from '../../model/News';
import { ColorConstants } from '../../constant/ColorConstants';

@Component
export struct NewsListItem {
  @Prop news: NewsItem = {
    id: '',
    title: '',
    summary: '',
    content: '',
    category: '',
    publishTime: '',
    author: '',
    views: 0
  };
  onNewsClick?: (news: NewsItem) => void;

  @State isPressed: boolean = false;

  build() {
    // iOS风格列表项：左缩略图，中标题+副标题，右箭头指示器
    Row() {
      // 左侧缩略图（圆角8px）
      Column() {
        Text('📰')
          .fontSize(24)
      }
      .width(76)
      .height(76)
      .backgroundColor(ColorConstants.BG_SECONDARY)
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)
      .margin({ right: 12 })

      // 中间内容：标题 + 来源时间
      Column() {
        Text(this.news.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(ColorConstants.TEXT_PRIMARY)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .lineHeight(22)

        // 来源 + 时间（副标题）
        Row() {
          Text(this.news.author)
            .fontSize(13)
            .fontColor(ColorConstants.TEXT_SECONDARY)
          Text('·')
            .fontSize(13)
            .fontColor(ColorConstants.TEXT_TERTIARY)
            .margin({ left: 4, right: 4 })
          Text(this.news.publishTime.substring(5, 16))
            .fontSize(13)
            .fontColor(ColorConstants.TEXT_SECONDARY)
        }
        .width('100%')
        .margin({ top: 6 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 右侧箭头指示器（iOS风格chevron）
      Text('›')
        .fontSize(28)
        .fontColor(ColorConstants.TEXT_TERTIARY)
        .margin({ left: 8 })
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .scale({ x: this.isPressed ? 0.98 : 1, y: this.isPressed ? 0.98 : 1 })
    .opacity(this.isPressed ? 0.7 : 1)
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
      this.onNewsClick?.(this.news);
    })
  }
}
