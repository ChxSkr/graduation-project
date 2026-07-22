import { CardViewModel } from '../../viewmodel/CardViewModel';
import { RecordItem } from '../../components/card/RecordItem';
import { ConsumptionRecord } from '../../model/CampusCard';
import { ColorConstants } from '../../constant/ColorConstants';
import { BackButton } from '../../components/common/BackButton';

@Entry
@Component
export struct RecordPage {
  @State viewModel: CardViewModel = new CardViewModel();
  @State currentTab: number = 0;

  private tabs: string[] = ['全部', '充值', '消费'];

  aboutToAppear(): void {
    this.viewModel.loadRecords();
  }

  @Builder
  MonthGroup(month: string, records: ConsumptionRecord[]) {
    Column() {
      Row() {
        Text(month)
          .fontSize(13)
          .fontColor(ColorConstants.TEXT_SECONDARY)
          .layoutWeight(1)
        // 月统计
        Text('月支出：¥' + this.viewModel.getMonthlySummary(month).totalConsume.toFixed(2))
          .fontSize(12)
          .fontColor(ColorConstants.TEXT_TERTIARY)
      }
      .width('100%')
      .padding({ top: 8, bottom: 8 })
      .backgroundColor(ColorConstants.BG_PAGE)

      Column() {
        ForEach(records, (record: ConsumptionRecord, index: number) => {
          RecordItem({ record: record })
          if (index < records.length - 1) {
            Divider().color(ColorConstants.DIVIDER)
          }
        }, (record: ConsumptionRecord) => record.id)
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .backgroundColor(ColorConstants.BG_CARD)
      .borderRadius(12)
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        BackButton({ style: 'text' })
        Text('消费记录')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(ColorConstants.TEXT_PRIMARY)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text(' ')
          .width(80)
      }
      .width('100%')
      .height(50)
      .padding({ left: 16, right: 16 })
      .backgroundColor(ColorConstants.BG_CARD)

      // Tab 切换
      Row() {
        ForEach(this.tabs, (tab: string, index: number) => {
          Text(tab)
            .fontSize(14)
            .fontColor(this.currentTab === index ? ColorConstants.PRIMARY : ColorConstants.TEXT_SECONDARY)
            .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)
            .width('33.33%')
            .textAlign(TextAlign.Center)
            .padding({ top: 12, bottom: 12 })
            .onClick(() => {
              this.currentTab = index;
              const types = ['all', 'recharge', 'consume'];
              this.viewModel.setFilterType(types[index]);
            })
        }, (tab: string) => tab)
      }
      .width('100%')
      .backgroundColor(ColorConstants.BG_CARD)

      // 列表
      Scroll() {
        Column() {
          if (this.viewModel.getRecordsByMonth().size === 0) {
            Column() {
              Text('暂无记录')
                .fontSize(14)
                .fontColor(ColorConstants.TEXT_TERTIARY)
            }
            .width('100%')
            .height(300)
            .justifyContent(FlexAlign.Center)
          } else {
            // 按月分组展示
            ForEach(Array.from(this.viewModel.getRecordsByMonth().keys()), (month: string) => {
              this.MonthGroup(month, this.viewModel.getRecordsByMonth().get(month) || [])
            }, (month: string) => month)
          }
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }
}
