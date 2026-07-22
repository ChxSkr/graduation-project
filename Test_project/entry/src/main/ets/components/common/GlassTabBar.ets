import { ColorConstants } from '../../constant/ColorConstants';

export interface TabItem {
  title: string;
  icon: ResourceStr;
  activeIcon: ResourceStr;
}

@Component
export struct GlassTabBar {
  @Prop tabs: TabItem[] = [];
  @Link currentIndex: number;
  @State sliderOffset: number = 0;
  onTabChange?: (index: number) => void;

  // iOS系统蓝色
  private readonly IOS_BLUE: string = '#007AFF';
  // iOS未选中灰色
  private readonly IOS_GRAY: string = '#8E8E93';

  aboutToAppear(): void {
    this.updateSliderPosition();
  }

  updateSliderPosition(): void {
    const tabWidth = 100 / this.tabs.length;
    this.sliderOffset = this.currentIndex * tabWidth + (tabWidth - 12) / 2;
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // iOS风格滑块指示器
      Row() {
        Column()
          .width('12%')
          .height(5)
          .borderRadius(2.5)
          .backgroundColor(this.IOS_BLUE)
          .margin({ left: `${this.sliderOffset}%` })
          .animation({
            duration: 250,
            curve: Curve.FastOutSlowIn
          })
      }
      .width('100%')
      .margin({ bottom: 50 })

      // iOS风格TabBar主体
      Column() {
        // 顶部细线分隔线
        Row()
          .width('100%')
          .height(0.5)
          .backgroundColor('rgba(60, 60, 67, 0.29)')

        // Tab内容
        Row() {
          ForEach(this.tabs, (tab: TabItem, index: number) => {
            this.TabBarItem(tab, index)
          }, (tab: TabItem, index: number) => index.toString())
        }
        .width('100%')
        .height(49)
        .justifyContent(FlexAlign.SpaceEvenly)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      // iOS透明玻璃效果
      .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
      .backgroundColor('rgba(248, 248, 248, 0.92)')
      .borderRadius({ topLeft: 0, topRight: 0 })
    }
    .width('100%')
    .height(50)
  }

  @Builder
  TabBarItem(tab: TabItem, index: number) {
    Column() {
      // iOS风格图标
      Text(this.currentIndex === index ? tab.activeIcon : tab.icon)
        .fontSize(25)
        .fontColor(this.currentIndex === index ? this.IOS_BLUE : this.IOS_GRAY)
        .animation({
          duration: 200,
          curve: Curve.EaseOut
        })

      // iOS风格标题
      Text(tab.title)
        .fontSize(10)
        .fontColor(this.currentIndex === index ? this.IOS_BLUE : this.IOS_GRAY)
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)
        .margin({ top: 4 })
    }
    .width('20%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (this.currentIndex !== index) {
        this.currentIndex = index;
        this.updateSliderPosition();
        this.onTabChange?.(index);
      }
    })
  }
}
