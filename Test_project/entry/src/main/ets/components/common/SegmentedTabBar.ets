import { ColorConstants } from '../../constant/ColorConstants';

export interface SegTabItem {
  title: string;
  icon: string;
}

/**
 * 分段控件风格底部导航栏
 * 参考 iOS Segmented Control：胶囊灰底 + 白色滑块指示器
 * 支持点击标签切换，也支持左右滑动滑块切换内容
 */
@Component
export struct SegmentedTabBar {
  @Prop tabs: SegTabItem[] = [];
  @Link @Watch('onCurrentChanged') currentIndex: number;
  @State pressedIndex: number = -1;
  @State sliderPosition: number = 0;
  @State sliderScale: number = 1; // 滑块缩放状态
  onTabChange?: (index: number) => void;

  private readonly PILL_HEIGHT: number = 46;
  private readonly ITEM_ICON_SIZE: number = 20;
  private readonly ITEM_TEXT_SIZE: number = 10;
  // 容器实际宽度（用于拖动位移换算）
  private containerWidth: number = 0;
  // 拖动起始时滑块所在位置
  private dragStartPos: number = 0;

  aboutToAppear(): void {
    this.sliderPosition = this.currentIndex;
  }

  // currentIndex 变化时，滑块带动画滑动到新位置（带缩放弹性效果）
  private onCurrentChanged(): void {
    // 先缩小
    animateTo({ duration: 120, curve: Curve.EaseOut }, () => {
      this.sliderScale = 0.85;
    });
    // 然后滑动并放大
    setTimeout(() => {
      animateTo({ duration: 280, curve: Curve.EaseOut }, () => {
        this.sliderPosition = this.currentIndex;
        this.sliderScale = 1;
      });
    }, 120);
  }

  build() {
    Row() {
      Stack({ alignContent: Alignment.Start }) {
        // 白色滑块指示器（宽度 = 1/段数，通过 translate 滑动 + scale 缩放）
        Row()
          .width(`${100 / this.tabs.length}%`)
          .height('100%')
          .backgroundColor(ColorConstants.BG_CARD)
          .borderRadius(this.PILL_HEIGHT / 2 - 3)
          .shadow({
            radius: 6,
            color: 'rgba(20, 40, 90, 0.10)',
            offsetX: 0,
            offsetY: 2
          })
          .translate({ x: `${this.sliderPosition * 100}%` })
          .scale({ x: this.sliderScale, y: this.sliderScale })

        // 分段项（图标 + 文字，叠加在滑块之上）
        Row() {
          ForEach(this.tabs, (tab: SegTabItem, index: number) => {
            this.SegItemBuilder(tab, index)
          }, (tab: SegTabItem, index: number) => tab.title + index)
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height(this.PILL_HEIGHT)
      .backgroundColor(ColorConstants.BG_SECONDARY)
      .borderRadius(this.PILL_HEIGHT / 2)
      .onAreaChange((_oldValue: Area, newValue: Area) => {
        this.containerWidth = newValue.width as number;
      })
      // 左右滑动滑块切换内容
      .gesture(
        PanGesture({ direction: PanDirection.Horizontal, distance: 5 })
          .onActionStart(() => {
            this.dragStartPos = this.sliderPosition;
          })
          .onActionUpdate((event: GestureEvent) => {
            if (this.containerWidth <= 0) return;
            const stepWidth = this.containerWidth / this.tabs.length;
            const stepsDelta = event.offsetX / stepWidth;
            let newPos = this.dragStartPos + stepsDelta;
            newPos = Math.max(0, Math.min(this.tabs.length - 1, newPos));
            this.sliderPosition = newPos;
          })
          .onActionEnd(() => {
            // 吸附到最近的分段
            const targetIndex = Math.round(this.sliderPosition);
            if (this.currentIndex !== targetIndex) {
              this.currentIndex = targetIndex;
              this.onTabChange?.(targetIndex);
            } else {
              // index 未变（拖动后回到原段）也要吸附归位
              animateTo({ duration: 200, curve: Curve.EaseOut }, () => {
                this.sliderPosition = targetIndex;
              });
            }
          })
      )
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
    .backgroundColor(ColorConstants.TAB_BAR_BG)
    .border({
      width: { top: 0.5 },
      color: { top: ColorConstants.DIVIDER }
    })
  }

  /**
   * 单个分段项构建器
   */
  @Builder
  SegItemBuilder(tab: SegTabItem, index: number) {
    Column({ space: 2 }) {
      // 图标
      Text(tab.icon)
        .fontSize(this.ITEM_ICON_SIZE)
        .fontColor(this.currentIndex === index
          ? ColorConstants.TAB_BAR_ITEM_ACTIVE
          : ColorConstants.TAB_BAR_ITEM_NORMAL)
        .animation({ duration: 250, curve: Curve.EaseOut })

      // 文字标签
      Text(tab.title)
        .fontSize(this.ITEM_TEXT_SIZE)
        .fontColor(this.currentIndex === index
          ? ColorConstants.TAB_BAR_ITEM_ACTIVE
          : ColorConstants.TAB_BAR_ITEM_NORMAL)
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Regular)
        .animation({ duration: 250, curve: Curve.EaseOut })
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.pressedIndex = index;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.pressedIndex = -1;
      }
    })
    .onClick(() => {
      if (this.currentIndex !== index) {
        this.currentIndex = index;
        this.onTabChange?.(index);
      }
    })
  }
}
