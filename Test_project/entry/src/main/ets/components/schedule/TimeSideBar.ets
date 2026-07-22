import { ColorConstants } from '../../constant/ColorConstants';
import { DateUtil } from '../../utils/DateUtil';

@Component
export struct TimeSideBar {
  totalSections: number = 12;
  sectionHeight: number = 60;

  @Builder
  SectionItem(section: number) {
    Column() {
      Text(section.toString())
        .fontSize(12)
        .fontColor(ColorConstants.TEXT_SECONDARY)
      Text(DateUtil.getSectionTime(section))
        .fontSize(10)
        .fontColor(ColorConstants.TEXT_TERTIARY)
        .margin({ top: 2 })
    }
    .width(40)
    .height(this.sectionHeight)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], (section: number) => {
        this.SectionItem(section)
      }, (section: number) => section.toString())
    }
    .width(40)
    .backgroundColor(ColorConstants.BG_CARD)
  }
}
