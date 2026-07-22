import { NewsItem } from '../../model/News';
import { ColorConstants } from '../../constant/ColorConstants';

@Component
export struct NewsBanner {
  newsList: NewsItem[] = [];
  @State currentIndex: number = 0;
  onItemClick?: (news: NewsItem) => void;

  @Builder
  BannerItem(news: NewsItem, index: number) {
    Stack() {
      // 渐变背景（iOS系统色系）
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            [this.getBannerColor(index), 1.0],
            [this.getBannerColorLight(index), 0.3]
          ]
        })

      Column() {
        // 毛玻璃文字区域
        Column() {
          Text(news.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')

          Text(news.summary)
            .fontSize(12)
            .fontColor('rgba(255, 255, 255, 0.8)')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .margin({ top: 6 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor('rgba(0, 0, 0, 0.2)')
        .backdropBlur(10)

        // iOS风格指示器（当前页为胶囊状）
        Row() {
          ForEach(this.newsList, (_: NewsItem, i: number) => {
            if (this.currentIndex === i) {
              // 当前页：胶囊形状
              Rect({ width: 16, height: 6 })
                .fill('#FFFFFF')
                .borderRadius(3)
                .margin({ right: 6 })
            } else {
              // 其他页：小圆点
              Circle({ width: 6, height: 6 })
                .fill('rgba(255, 255, 255, 0.4)')
                .margin({ right: 6 })
            }
          }, (_: NewsItem, i: number) => i.toString())
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ bottom: 12, top: 8 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height(140)
    .borderRadius(16)
    .shadow({
      radius: 10,
      color: 'rgba(0, 0, 0, 0.08)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      this.onItemClick?.(news);
    })
  }

  build() {
    if (this.newsList.length > 0) {
      Swiper() {
        ForEach(this.newsList, (news: NewsItem, index: number) => {
          this.BannerItem(news, index)
        }, (news: NewsItem) => news.id)
      }
      .width('100%')
      .height(140)
      .autoPlay(true)
      .interval(3000)
      .indicator(false)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
    }
  }

  private getBannerColor(index: number): string {
    const colors: string[] = [
      ColorConstants.IOS_BLUE,
      ColorConstants.IOS_GREEN,
      ColorConstants.IOS_PURPLE,
      ColorConstants.IOS_PINK,
      ColorConstants.IOS_TEAL
    ];
    return colors[index % colors.length];
  }

  private getBannerColorLight(index: number): string {
    const colors: string[] = [
      '#5AC8FA',
      '#95DE64',
      '#C77DFF',
      '#FF85C0',
      '#A0D8FF'
    ];
    return colors[index % colors.length];
  }
}
