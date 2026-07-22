import router from '@ohos.router';
import { ColorConstants } from '../../constant/ColorConstants';

/**
 * 统一的返回按钮组件
 * 采用 iOS 风格设计，支持两种样式：
 * 1. 符号样式（默认）- 只显示 ‹ 符号
 * 2. 文字样式 - 显示 "< 返回"
 */
@Component
export struct BackButton {
  // 样式类型：'symbol' | 'text'
  @Prop style: 'symbol' | 'text' = 'symbol';
  // 自定义颜色（默认使用主题色）
  @Prop color: ResourceColor = ColorConstants.PRIMARY;
  // 点击回调（可选，默认执行 router.back()）
  onBack?: () => void;

  build() {
    if (this.style === 'symbol') {
      // 符号样式 - iOS 风格
      Text('‹')
        .fontSize(28)
        .fontColor(this.color)
        .fontWeight(FontWeight.Lighter)
        .width(44)
        .height(44)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          if (this.onBack) {
            this.onBack();
          } else {
            router.back();
          }
        })
    } else {
      // 文字样式
      Text('< 返回')
        .fontSize(16)
        .fontColor(this.color)
        .width(80)
        .height(44)
        .textAlign(TextAlign.Start)
        .onClick(() => {
          if (this.onBack) {
            this.onBack();
          } else {
            router.back();
          }
        })
    }
  }
}
