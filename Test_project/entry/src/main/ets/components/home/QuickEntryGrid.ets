import { QuickEntry } from '../../model/QuickEntry';
import { ColorConstants, GradientColor, BadgeConfig } from '../../constant/ColorConstants';

// 单个快捷入口项组件（HarmonyOS高质感风格）
@Component
export struct QuickEntryItem {
  entry!: QuickEntry;
  index!: number;
  showBadge?: boolean = false;
  badgeText?: string = '';
  onItemClick?: (entry: QuickEntry) => void;

  @State isPressed: boolean = false;

  // 获取当前项对应的渐变色
  private getGradient(): GradientColor {
    const gradients = ColorConstants.QUICK_ENTRY_GRADIENTS;
    return gradients[this.index % gradients.length];
  }

  build() {
    Column() {
      // 图标容器（渐变背景 + 光泽 + 阴影）
      Stack({ alignContent: Alignment.TopEnd }) {
        // 渐变背景
        Stack() {
          Text(this.entry.icon)
            .fontSize(26)
            .fontColor(Color.White)
        }
        .width(54)
        .height(54)
        .borderRadius(17)
        .linearGradient({
          direction: GradientDirection.RightBottom,
          colors: [
            [this.getGradient().start, 0],
            [this.getGradient().end, 1]
          ]
        })
        .shadow({
          radius: 10,
          color: this.getGradient().start + '55',
          offsetX: 0,
          offsetY: 4
        })

        // 左上光泽高光（使用半透明白色渐变模拟）
        Stack() {
          Column()
            .width('100%')
            .height('55%')
            .linearGradient({
              direction: GradientDirection.Bottom,
              colors: [
                ['rgba(255, 255, 255, 0.42)', 0],
                ['rgba(255, 255, 255, 0.05)', 1]
              ]
            })
        }
        .width(54)
        .height(54)
        .borderRadius(17)
        .clip(true)

        // 右上角小红点 / Badge
        if (this.showBadge) {
          if (this.badgeText && this.badgeText.length > 0) {
            Text(this.badgeText)
              .fontSize(10)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
              .padding({ left: 5, right: 5, top: 2, bottom: 2 })
              .constraintSize({ minWidth: 16 })
              .height(16)
              .textAlign(TextAlign.Center)
              .backgroundColor(ColorConstants.ERROR)
              .borderRadius(8)
              .margin({ top: -3, right: -3 })
          } else {
            Circle()
              .width(8)
              .height(8)
              .fill(ColorConstants.ERROR)
              .margin({ top: 2, right: 2 })
          }
        }
      }

      // 入口名称
      Text(this.entry.name)
        .fontSize(11.5)
        .fontWeight(FontWeight.Medium)
        .fontColor(ColorConstants.TEXT_PRIMARY)
        .margin({ top: 8 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .justifyContent(FlexAlign.Center)
    .scale({ x: this.isPressed ? 0.92 : 1.0, y: this.isPressed ? 0.92 : 1.0 })
    .animation({
      duration: 120,
      curve: Curve.EaseInOut,
      playMode: PlayMode.Normal
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        animateTo({ duration: 120, curve: Curve.EaseIn }, () => {
          this.isPressed = true;
        });
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        animateTo({ duration: 180, curve: Curve.EaseOut }, () => {
          this.isPressed = false;
        });
        if (event.type === TouchType.Up) {
          this.onItemClick?.(this.entry);
        }
      }
    })
  }
}

@Component
export struct QuickEntryGrid {
  entries: QuickEntry[] = [];
  onItemClick?: (entry: QuickEntry) => void;

  // badge 配置（按 index 标记，可根据业务需要扩展）
  private readonly badgeIndices: Map<number, BadgeConfig> = new Map();

  build() {
    Row() {
      ForEach(
        this.entries,
        (entry: QuickEntry, index: number) => {
          QuickEntryItem({
            entry: entry,
            index: index,
            showBadge: this.badgeIndices.get(index)?.show ?? false,
            badgeText: this.badgeIndices.get(index)?.text ?? '',
            onItemClick: (e: QuickEntry) => {
              this.onItemClick?.(e);
            }
          })
          .layoutWeight(1)
        },
        (entry: QuickEntry) => entry.id
      )
    }
    .width('100%')
    .padding({ left: 8, right: 8, top: 14, bottom: 14 })
    .backgroundColor(ColorConstants.BG_CARD)
    .borderRadius(24)
    .shadow({
      radius: 16,
      color: 'rgba(20, 40, 90, 0.08)',
      offsetX: 0,
      offsetY: 4
    })
    .border({
      width: 0.5,
      color: 'rgba(255, 255, 255, 0.9)'
    })
  }
}
