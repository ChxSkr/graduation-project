import { NewsCategory } from '../../model/News';
import { ColorConstants } from '../../constant/ColorConstants';

@Component
export struct CategoryTabs {
  @Prop categories: NewsCategory[] = [];
  @Prop currentCategory: string = 'all';
  onSelect?: (categoryId: string) => void;

  build() {
    // iOS Segmented Control 风格：圆角胶囊形分段控件，灰色背景，白色选中块
    Row() {
      ForEach(this.categories, (cat: NewsCategory) => {
        Text(cat.name)
          .fontSize(13)
          .fontWeight(this.currentCategory === cat.id ? FontWeight.Medium : FontWeight.Regular)
          .fontColor(this.currentCategory === cat.id ? ColorConstants.TEXT_PRIMARY : ColorConstants.TEXT_SECONDARY)
          .layoutWeight(1)
          .height(28)
          .textAlign(TextAlign.Center)
          .backgroundColor(this.currentCategory === cat.id ? ColorConstants.BG_CARD : ColorConstants.TRANSPARENT)
          .borderRadius(7)
          .onClick(() => {
            this.onSelect?.(cat.id);
          })
      }, (cat: NewsCategory) => cat.id)
    }
    .width('100%')
    .padding(2)
    .backgroundColor(ColorConstants.BG_SECONDARY)
    .borderRadius(9)
  }
}
