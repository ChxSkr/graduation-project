import { LostFoundViewModel, Category } from '../../viewmodel/LostFoundViewModel';
import { LostFoundItemCard } from '../../components/lostfound/LostFoundItem';
import { LostFoundItem } from '../../model/LostFound';
import { ColorConstants } from '../../constant/ColorConstants';
import { CommonUtil } from '../../utils/CommonUtil';
import router from '@ohos.router';

@Entry
@Component
export struct LostFoundPage {
  @State viewModel: LostFoundViewModel = new LostFoundViewModel();
  @State showCategoryPicker: boolean = false;
  @State isRefreshing: boolean = false;
  @State fabPressed: boolean = false;
  @State listOpacity: number = 1.0;
  @State searchText: string = '';

  aboutToAppear(): void {
    this.viewModel.loadItems();
  }

  // 下拉刷新处理
  private async onRefresh(): Promise<void> {
    if (this.isRefreshing) return;
    this.isRefreshing = true;
    try {
      await this.viewModel.loadItems();
      CommonUtil.showToast('刷新成功');
    } finally {
      this.isRefreshing = false;
    }
  }

  // iOS 风格搜索栏
  @Builder
  SearchBar() {
    Row() {
      Text('🔍')
        .fontSize(14)
        .margin({ left: 10, right: 6 })

      TextInput({ placeholder: '搜索标题或地点', text: this.searchText })
        .fontSize(15)
        .placeholderColor(ColorConstants.TEXT_TERTIARY)
        .backgroundColor(ColorConstants.TRANSPARENT)
        .layoutWeight(1)
        .height(36)
        .onChange((val: string) => {
          this.searchText = val;
          this.viewModel.setSearchKeyword(val);
        })

      if (this.searchText.length > 0) {
        Text('✕')
          .fontSize(14)
          .fontColor(ColorConstants.TEXT_TERTIARY)
          .width(20)
          .height(20)
          .textAlign(TextAlign.Center)
          .margin({ right: 10 })
          .onClick(() => {
            this.searchText = '';
            this.viewModel.setSearchKeyword('');
          })
      }
    }
    .width('100%')
    .height(36)
    .backgroundColor(ColorConstants.BG_SECONDARY)
    .borderRadius(10)
    .margin({ left: 20, right: 20, bottom: 12 })
  }

  // iOS Segmented Control 样式的类型切换（带滑块动画）
  @Builder
  SegmentedTab() {
    Stack({ alignContent: Alignment.Start }) {
      // 背景滑块
      Row() {
        Column() {}
        .width('50%')
        .height('100%')
        .backgroundColor(ColorConstants.BG_CARD)
        .borderRadius(7)
        .shadow({
          radius: 2,
          color: 'rgba(0, 0, 0, 0.08)',
          offsetX: 0,
          offsetY: 1
        })
      }
      .width('100%')
      .height('100%')
      .padding(2)
      .translate({
        x: this.viewModel.currentType === 'lost' ? 0 : '100%'
      })
      .animation({
        duration: 250,
        curve: Curve.EaseOut,
        playMode: PlayMode.Normal
      })

      Row() {
        Text('寻物启事')
          .fontSize(13)
          .fontWeight(this.viewModel.currentType === 'lost' ? FontWeight.Medium : FontWeight.Regular)
          .fontColor(this.viewModel.currentType === 'lost' ? ColorConstants.TEXT_PRIMARY : ColorConstants.TEXT_SECONDARY)
          .width('50%')
          .height(28)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            if (this.viewModel.currentType !== 'lost') {
              this.listOpacity = 0;
              this.viewModel.setType('lost');
              setTimeout(() => {
                this.listOpacity = 1;
              }, 50);
            }
          })

        Text('招领启事')
          .fontSize(13)
          .fontWeight(this.viewModel.currentType === 'found' ? FontWeight.Medium : FontWeight.Regular)
          .fontColor(this.viewModel.currentType === 'found' ? ColorConstants.TEXT_PRIMARY : ColorConstants.TEXT_SECONDARY)
          .width('50%')
          .height(28)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            if (this.viewModel.currentType !== 'found') {
              this.listOpacity = 0;
              this.viewModel.setType('found');
              setTimeout(() => {
                this.listOpacity = 1;
              }, 50);
            }
          })
      }
      .width('100%')
      .height(32)
      .padding(2)
    }
    .width('100%')
    .height(32)
    .backgroundColor(ColorConstants.BG_SECONDARY)
    .borderRadius(9)
  }

  // iOS 风格胶囊形分类标签（选中有缩放+阴影效果）
  @Builder
  CategoryChip(cat: Category, isSelected: boolean) {
    Text(cat.name)
      .fontSize(14)
      .fontWeight(isSelected ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(isSelected ? '#FFFFFF' : ColorConstants.TEXT_PRIMARY)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(isSelected ? ColorConstants.IOS_BLUE : ColorConstants.BG_CARD)
      .borderRadius(18)
      .margin({ right: 8 })
      .scale({ x: isSelected ? 1.05 : 1.0, y: isSelected ? 1.05 : 1.0 })
      .shadow({
        radius: isSelected ? 8 : 0,
        color: isSelected ? 'rgba(0, 122, 255, 0.35)' : 'rgba(0,0,0,0)',
        offsetX: 0,
        offsetY: isSelected ? 2 : 0
      })
      .animation({
        duration: 200,
        curve: Curve.EaseOut
      })
      .onClick(() => {
        this.viewModel.setCategory(cat.id);
      })
  }

  // 空状态视图
  @Builder
  EmptyState() {
    Column() {
      Text(this.viewModel.currentType === 'lost' ? '🔍' : '📦')
        .fontSize(64)
        .margin({ bottom: 16 })

      Text(this.searchText.length > 0
        ? '没有找到相关结果'
        : (this.viewModel.currentType === 'lost' ? '暂无寻物启事' : '暂无招领启事'))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(ColorConstants.TEXT_PRIMARY)
        .margin({ bottom: 8 })

      Text(this.searchText.length > 0
        ? '试试其他关键词吧'
        : '快来发布第一条信息吧~')
        .fontSize(14)
        .fontColor(ColorConstants.TEXT_SECONDARY)
    }
    .width('100%')
    .height(300)
    .justifyContent(FlexAlign.Center)
  }

  // 列表内容
  @Builder
  ListContent() {
    Column() {
      if (this.viewModel.getFilteredItems().length === 0) {
        this.EmptyState()
      } else {
        Column() {
          ForEach(this.viewModel.getFilteredItems(), (item: LostFoundItem, index: number) => {
            LostFoundItemCard({
              item: item,
              isFirst: index === 0,
              isLast: index === this.viewModel.getFilteredItems().length - 1,
              onCardClick: (i: LostFoundItem) => {
                router.pushUrl({ url: 'pages/lostfound/LostFoundDetailPage', params: { id: i.id } });
              }
            })
            if (index < this.viewModel.getFilteredItems().length - 1) {
              Divider()
                .color(ColorConstants.DIVIDER)
                .margin({ left: 84 })
            }
          }, (item: LostFoundItem) => item.id)
        }
        .width('100%')
        .backgroundColor(ColorConstants.BG_CARD)
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 8 })
        .clip(true)
      }
    }
    .width('100%')
    .padding({ bottom: 100 })
    .opacity(this.listOpacity)
    .animation({
      duration: 300,
      curve: Curve.EaseOut
    })
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        // iOS 大标题导航栏
        Column() {
          Text('失物招领')
            .fontSize(34)
            .fontWeight(FontWeight.Bold)
            .fontColor(ColorConstants.TEXT_PRIMARY)
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ left: 20, right: 20, top: 8, bottom: 12 })
        }
        .width('100%')
        .backgroundColor(ColorConstants.BG_PAGE)

        // 搜索栏
        this.SearchBar()

        // Segmented Control
        Row() {
          this.SegmentedTab()
        }
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 12 })
        .backgroundColor(ColorConstants.BG_PAGE)

        // 分类筛选 - 横向滚动胶囊标签
        Scroll() {
          Row() {
            ForEach(this.viewModel.categories, (cat: Category) => {
              this.CategoryChip(cat, this.viewModel.currentCategory === cat.id)
            }, (cat: Category) => cat.id)
          }
          .padding({ left: 20, right: 12 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .width('100%')
        .margin({ bottom: 8 })
        .backgroundColor(ColorConstants.BG_PAGE)

        // 列表 - iOS分组列表风格 + 下拉刷新
        List() {
          ListItem() {
            this.ListContent()
          }
          .width('100%')
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
        .backgroundColor(ColorConstants.BG_PAGE)
        .onScrollIndex((start: number, end: number) => {
          // 检测下拉刷新
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ColorConstants.BG_PAGE)

      // 胶囊形发布按钮（底部居中 + 半透明）
      Row() {
        Text('＋ 发布')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)
      }
      .width(120)
      .height(48)
      .borderRadius(24)
      .linearGradient({
        direction: GradientDirection.LeftBottom,
        colors: [
          [ColorConstants.PRIMARY, 0.0],
          [ColorConstants.TEAL, 1.0]
        ]
      })
      .justifyContent(FlexAlign.Center)
      .shadow({
        radius: 12,
        color: 'rgba(10, 89, 247, 0.25)',
        offsetX: 0,
        offsetY: 4
      })
      .opacity(0.85)
      .scale({ x: this.fabPressed ? 0.95 : 1.0, y: this.fabPressed ? 0.95 : 1.0 })
      .animation({
        duration: 150,
        curve: Curve.EaseInOut
      })
      .margin({ bottom: 24 })
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.fabPressed = true;
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.fabPressed = false;
        }
      })
      .onClick(() => {
        router.pushUrl({ url: 'pages/lostfound/PublishPage' });
      })
    }
    .width('100%')
    .height('100%')
  }
}
