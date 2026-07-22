import { LostFoundViewModel } from '../../viewmodel/LostFoundViewModel';
import { LostFoundItemCard } from '../../components/lostfound/LostFoundItem';
import { LostFoundItem } from '../../model/LostFound';
import { ColorConstants } from '../../constant/ColorConstants';
import { CommonUtil } from '../../utils/CommonUtil';
import { ApiConfig } from '../../network/ApiConfig';
import router from '@ohos.router';

// 类型筛选选项接口
interface TypeOption {
  id: string;
  name: string;
}

/**
 * 我的发布页面
 * 与"我的"页面采用相同的 iOS 分组列表风格
 * 通过后端 /lostFound/my 接口按当前登录用户过滤
 */
@Entry
@Component
export struct MyPublishPage {
  @State viewModel: LostFoundViewModel = new LostFoundViewModel();
  @StorageLink('darkMode') isDarkMode: boolean = false;

  @State listOpacity: number = 1.0;
  @State fabPressed: boolean = false;
  @State menuVisible: boolean = false;

  // 类型筛选选项（"我的发布"需要"全部"以查看所有类型）
  private readonly typeOptions: TypeOption[] = [
    { id: 'all', name: '全部' },
    { id: 'lost', name: '寻物启事' },
    { id: 'found', name: '招领启事' }
  ];

  aboutToAppear(): void {
    // 未登录直接返回，避免空请求
    if (!ApiConfig.isLoggedIn()) {
      CommonUtil.showToast('请先登录');
      router.back();
      return;
    }
    this.viewModel.myType = 'all';
    this.viewModel.loadMyItems();
    setTimeout(() => {
      this.menuVisible = true;
    }, 100);
  }

  // 深色模式颜色辅助方法（与 ProfilePage 一致）
  private getTextPrimary(): string {
    return this.isDarkMode ? ColorConstants.DARK_TEXT_PRIMARY : ColorConstants.TEXT_PRIMARY;
  }

  private getTextSecondary(): string {
    return this.isDarkMode ? ColorConstants.DARK_TEXT_SECONDARY : ColorConstants.TEXT_SECONDARY;
  }

  private getBgPage(): string {
    return this.isDarkMode ? ColorConstants.DARK_BG_PAGE : ColorConstants.BG_PAGE;
  }

  private getBgCard(): string {
    return this.isDarkMode ? ColorConstants.DARK_BG_CARD : ColorConstants.BG_CARD;
  }

  private getDividerColor(): string {
    return this.isDarkMode ? ColorConstants.DARK_DIVIDER : ColorConstants.DIVIDER;
  }

  // iOS 风格 Segmented Control（三段：全部 / 寻物 / 招领）
  @Builder
  SegmentedTab() {
    Stack({ alignContent: Alignment.Start }) {
      // 背景滑块 - 使用 position 绝对定位，纯百分比计算
      Column() {
      }
      .width('33.33%')
      .height(28)
      .backgroundColor(this.getBgCard())
      .borderRadius(7)
      .shadow({
        radius: 2,
        color: 'rgba(0, 0, 0, 0.08)',
        offsetX: 0,
        offsetY: 1
      })
      .position({
        x: this.viewModel.myType === 'all' ? 0 : (this.viewModel.myType === 'lost' ? '33.33%' : '66.66%'),
        y: 2
      })
      .animation({
        duration: 250,
        curve: Curve.EaseOut,
        playMode: PlayMode.Normal
      })

      // 文字层 - 同样使用纯百分比，确保与滑块对齐
      Row() {
        Text('全部')
          .fontSize(13)
          .fontWeight(this.viewModel.myType === 'all' ? FontWeight.Medium : FontWeight.Regular)
          .fontColor(this.viewModel.myType === 'all' ? this.getTextPrimary() : this.getTextSecondary())
          .width('33.33%')
          .height(28)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            if (this.viewModel.myType !== 'all') {
              this.listOpacity = 0;
              this.viewModel.setMyType('all');
              setTimeout(() => {
                this.listOpacity = 1;
              }, 50);
            }
          })

        Text('寻物启事')
          .fontSize(13)
          .fontWeight(this.viewModel.myType === 'lost' ? FontWeight.Medium : FontWeight.Regular)
          .fontColor(this.viewModel.myType === 'lost' ? this.getTextPrimary() : this.getTextSecondary())
          .width('33.33%')
          .height(28)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            if (this.viewModel.myType !== 'lost') {
              this.listOpacity = 0;
              this.viewModel.setMyType('lost');
              setTimeout(() => {
                this.listOpacity = 1;
              }, 50);
            }
          })

        Text('招领启事')
          .fontSize(13)
          .fontWeight(this.viewModel.myType === 'found' ? FontWeight.Medium : FontWeight.Regular)
          .fontColor(this.viewModel.myType === 'found' ? this.getTextPrimary() : this.getTextSecondary())
          .width('33.33%')
          .height(28)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            if (this.viewModel.myType !== 'found') {
              this.listOpacity = 0;
              this.viewModel.setMyType('found');
              setTimeout(() => {
                this.listOpacity = 1;
              }, 50);
            }
          })
      }
      .width('100%')
      .height(32)
      .padding({ left: 2, right: 2 })
    }
    .width('100%')
    .height(32)
    .backgroundColor(this.isDarkMode ? 'rgba(255,255,255,0.08)' : ColorConstants.BG_SECONDARY)
    .borderRadius(9)
  }

  // 空状态视图
  @Builder
  EmptyState() {
    Column() {
      Text('📝')
        .fontSize(64)
        .margin({ bottom: 16 })

      Text('还没有发布过信息')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getTextPrimary())
        .margin({ bottom: 8 })

      Text('点击右下角按钮，发布你的第一条信息吧~')
        .fontSize(14)
        .fontColor(this.getTextSecondary())
        .textAlign(TextAlign.Center)
        .padding({ left: 40, right: 40 })
    }
    .width('100%')
    .height(300)
    .justifyContent(FlexAlign.Center)
  }

  // 加载中状态
  @Builder
  LoadingState() {
    Column() {
      Text('⏳')
        .fontSize(40)
        .margin({ bottom: 12 })

      Text('加载中...')
        .fontSize(14)
        .fontColor(this.getTextSecondary())
    }
    .width('100%')
    .height(300)
    .justifyContent(FlexAlign.Center)
  }

  // 列表内容
  @Builder
  ListContent() {
    Column() {
      if (this.viewModel.isMyLoading) {
        this.LoadingState()
      } else if (this.viewModel.myItemList.length === 0) {
        this.EmptyState()
      } else {
        Column() {
          ForEach(this.viewModel.myItemList, (item: LostFoundItem, index: number) => {
            LostFoundItemCard({
              item: item,
              isFirst: index === 0,
              isLast: index === this.viewModel.myItemList.length - 1,
              onCardClick: (i: LostFoundItem) => {
                router.pushUrl({ url: 'pages/lostfound/LostFoundDetailPage', params: { id: i.id } });
              }
            })
            if (index < this.viewModel.myItemList.length - 1) {
              Divider()
                .color(this.getDividerColor())
                .margin({ left: 84 })
            }
          }, (item: LostFoundItem) => item.id)
        }
        .width('100%')
        .backgroundColor(this.getBgCard())
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
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        // 顶部导航栏（iOS 风格：左返回 + 大标题 + 右发布入口）
        Row() {
          Text('‹')
            .fontSize(28)
            .fontColor(ColorConstants.IOS_BLUE)
            .fontWeight(FontWeight.Lighter)
            .width(40)
            .textAlign(TextAlign.Start)
            .onClick(() => {
              router.back();
            })

          Text('我的发布')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getTextPrimary())
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Text('发布')
            .fontSize(16)
            .fontColor(ColorConstants.IOS_BLUE)
            .width(60)
            .textAlign(TextAlign.End)
            .onClick(() => {
              router.pushUrl({ url: 'pages/lostfound/PublishPage' });
            })
        }
        .width('100%')
        .height(50)
        .padding({ left: 16, right: 16 })
        .backgroundColor(this.getBgPage())
        .border({
          width: { bottom: 0.5 },
          color: this.isDarkMode ? 'rgba(255,255,255,0.08)' : 'rgba(0, 0, 0, 0.1)'
        })

        // iOS 大标题
        Text('我的发布')
          .fontSize(34)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getTextPrimary())
          .width('100%')
          .textAlign(TextAlign.Start)
          .margin({ left: 20, right: 20, top: 8, bottom: 12 })
          .backgroundColor(this.getBgPage())
          .opacity(this.menuVisible ? 1 : 0)
          .translate({ y: this.menuVisible ? 0 : 10 })
          .animation({ duration: 400, curve: Curve.EaseOut })

        // 类型切换 Segmented Control
        Row() {
          this.SegmentedTab()
        }
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 12 })
        .backgroundColor(this.getBgPage())
        .opacity(this.menuVisible ? 1 : 0)
        .translate({ y: this.menuVisible ? 0 : 20 })
        .animation({ duration: 500, curve: Curve.EaseOut, delay: 80 })

        // 列表
        List() {
          ListItem() {
            this.ListContent()
          }
          .width('100%')
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
        .backgroundColor(this.getBgPage())
        .opacity(this.menuVisible ? 1 : 0)
        .animation({ duration: 500, curve: Curve.EaseOut, delay: 160 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.getBgPage())

      // iOS 风格圆形 FAB 发布按钮（与失物招领页一致）
      Column() {
        Column() {
          Text('+')
            .fontSize(28)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Lighter)
        }
        .width(56)
        .height(56)
        .borderRadius(28)
        .linearGradient({
          direction: GradientDirection.LeftBottom,
          colors: [
            [ColorConstants.PRIMARY, 0.0],
            [ColorConstants.TEAL, 1.0]
          ]
        })
        .justifyContent(FlexAlign.Center)
        .border({ width: 3, color: this.isDarkMode ? ColorConstants.DARK_BG_CARD : '#FFFFFF' })
        .shadow({
          radius: 16,
          color: 'rgba(10, 89, 247, 0.35)',
          offsetX: 0,
          offsetY: 4
        })
        .scale({ x: this.fabPressed ? 0.9 : 1.0, y: this.fabPressed ? 0.9 : 1.0 })
        .animation({
          duration: 150,
          curve: Curve.EaseInOut
        })
      }
      .margin({ right: 20, bottom: 24 })
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
