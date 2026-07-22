import { LostFoundItem } from '../../model/LostFound';
import { ColorConstants } from '../../constant/ColorConstants';
import { CommonUtil } from '../../utils/CommonUtil';
import { BackButton } from '../../components/common/BackButton';

@Entry
@Component
export struct LostFoundDetailPage {
  @State item: LostFoundItem | null = null;
  @State navBarOpacity: number = 0;
  @State showContactAlert: boolean = false;
  @State showCompleteAlert: boolean = false;
  @State callButtonPressed: boolean = false;
  @State msgButtonPressed: boolean = false;
  @State completeButtonPressed: boolean = false;

  // 滚动偏移量计算导航栏透明度
  private onScrollUpdate(scrollOffset: number): void {
    const maxOffset = 80;
    if (scrollOffset <= 0) {
      this.navBarOpacity = 0;
    } else if (scrollOffset >= maxOffset) {
      this.navBarOpacity = 1;
    } else {
      this.navBarOpacity = scrollOffset / maxOffset;
    }
  }

  // iOS 风格导航栏
  @Builder
  NavBar() {
    Row() {
      // 左返回按钮
      BackButton({ style: 'symbol', color: ColorConstants.IOS_BLUE })

      // 中间标题
      Text('详情')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(ColorConstants.TEXT_PRIMARY)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .opacity(this.navBarOpacity)
        .animation({ duration: 150, curve: Curve.EaseInOut })

      // 右更多按钮
      Column() {
        Text('⋯')
          .fontSize(20)
          .fontColor(ColorConstants.IOS_BLUE)
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        CommonUtil.showToast('更多操作');
      })
    }
    .width('100%')
    .height(50)
    .padding({ left: 4, right: 4 })
    .backgroundColor(`rgba(247, 247, 247, ${this.navBarOpacity * 0.92})`)
    .position({ x: 0, y: 0 })
    .zIndex(10)
  }

  // 大图/图标头部区域
  @Builder
  HeroSection() {
    Column() {
      Text(this.item?.type === 'lost' ? '🔍' : '📦')
        .fontSize(80)
        .margin({ bottom: 12 })

      Text(this.item?.type === 'lost' ? '寻物启事' : '失物招领')
        .fontSize(14)
        .fontColor(this.item?.type === 'lost' ? ColorConstants.IOS_ORANGE : ColorConstants.IOS_GREEN)
        .padding({ left: 14, right: 14, top: 6, bottom: 6 })
        .backgroundColor(this.item?.type === 'lost'
          ? 'rgba(255, 149, 0, 0.12)'
          : 'rgba(52, 199, 89, 0.12)')
        .borderRadius(14)
    }
    .width('100%')
    .height(220)
    .backgroundColor(this.item?.type === 'lost'
      ? 'rgba(255, 149, 0, 0.06)'
      : 'rgba(52, 199, 89, 0.06)')
    .justifyContent(FlexAlign.Center)
  }

  // 状态标签
  @Builder
  StatusBadge() {
    Row() {
      if (this.item?.status === 'completed') {
        Text('✓ 已完成')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(ColorConstants.IOS_GREEN)
          .borderRadius(12)
      } else {
        Text(this.item?.type === 'lost' ? '🔴 寻找中' : '🟢 待认领')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.item?.type === 'lost' ? ColorConstants.IOS_RED : ColorConstants.IOS_GREEN)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.item?.type === 'lost'
            ? 'rgba(255, 59, 48, 0.1)'
            : 'rgba(52, 199, 89, 0.1)')
          .borderRadius(12)
      }

      Text(this.item?.category || '')
        .fontSize(13)
        .fontColor(ColorConstants.TEXT_SECONDARY)
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor(ColorConstants.BG_SECONDARY)
        .borderRadius(12)
        .margin({ left: 8 })
    }
    .width('100%')
  }

  // 标题
  @Builder
  TitleSection() {
    Column() {
      this.StatusBadge()

      Text(this.item?.title || '')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(ColorConstants.TEXT_PRIMARY)
        .width('100%')
        .lineHeight(32)
        .margin({ top: 12 })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 20, bottom: 20 })
    .backgroundColor(ColorConstants.BG_CARD)
    .borderRadius(16)
    .margin({ left: 16, right: 16, top: -30, bottom: 12 })
  }

  // iOS 分组列表风格的信息行
  @Builder
  InfoRow(icon: string, label: string, value: string, isLast: boolean) {
    Row() {
      Text(icon)
        .fontSize(16)
        .width(28)

      Text(label)
        .fontSize(15)
        .fontColor(ColorConstants.TEXT_SECONDARY)
        .width(80)

      Text(value)
        .fontSize(15)
        .fontColor(ColorConstants.TEXT_PRIMARY)
        .layoutWeight(1)
        .textAlign(TextAlign.End)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })

    if (!isLast) {
      Divider()
        .color(ColorConstants.DIVIDER)
        .margin({ left: 60 })
    }
  }

  // 信息卡片组
  @Builder
  InfoCard() {
    Column() {
      this.InfoRow('📍', '地点', this.item?.location || '', false)
      this.InfoRow('⏰', '时间', this.item?.time || '未知', false)
      this.InfoRow('📱', '联系方式', this.item?.contact || '', false)
      this.InfoRow('🕐', '发布时间', this.item?.publishTime || '', true)
    }
    .width('100%')
    .backgroundColor(ColorConstants.BG_CARD)
    .borderRadius(16)
    .margin({ left: 16, right: 16, bottom: 12 })
    .clip(true)
  }

  // 描述卡片
  @Builder
  DescriptionCard() {
    Column() {
      Text('详细描述')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(ColorConstants.TEXT_SECONDARY)
        .width('100%')
        .margin({ bottom: 10 })

      Text(this.item?.description || '暂无描述')
        .fontSize(15)
        .fontColor(ColorConstants.TEXT_PRIMARY)
        .width('100%')
        .lineHeight(24)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(ColorConstants.BG_CARD)
    .borderRadius(16)
    .margin({ left: 16, right: 16, bottom: 100 })
    .clip(true)
  }

  // iOS 风格 Alert 对话框
  @Builder
  iOSAlert(title: string, message: string, cancelText: string, confirmText: string, confirmColor: string, onConfirm: () => void) {
    Stack({ alignContent: Alignment.Center }) {
      // 背景遮罩
      Column() {}
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.4)')

      // 弹窗内容
      Column() {
        Column() {
          Text(title)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(ColorConstants.TEXT_PRIMARY)
            .margin({ bottom: 4 })
            .textAlign(TextAlign.Center)

          Text(message)
            .fontSize(13)
            .fontColor(ColorConstants.TEXT_SECONDARY)
            .textAlign(TextAlign.Center)
            .lineHeight(18)
            .margin({ bottom: 20 })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 20, bottom: 0 })

        // 按钮区域
        Row() {
          Text(cancelText)
            .fontSize(17)
            .fontColor(ColorConstants.IOS_BLUE)
            .layoutWeight(1)
            .height(44)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.showContactAlert = false;
              this.showCompleteAlert = false;
            })

          Divider()
            .vertical(true)
            .color(ColorConstants.DIVIDER)
            .height(44)

          Text(confirmText)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(confirmColor)
            .layoutWeight(1)
            .height(44)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              onConfirm();
              this.showContactAlert = false;
              this.showCompleteAlert = false;
            })
        }
        .width('100%')
        .border({
          width: { top: 0.5 },
          color: ColorConstants.DIVIDER
        })
      }
      .width(270)
      .backgroundColor(ColorConstants.BG_CARD)
      .borderRadius(14)
      .clip(true)
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .zIndex(100)
  }

  // 底部操作栏（毛玻璃背景）
  @Builder
  BottomActionBar() {
    Column() {
      Row() {
        // 拨打电话按钮
        Column() {
          Text('📞')
            .fontSize(18)
          Text('电话')
            .fontSize(11)
            .fontColor(ColorConstants.IOS_BLUE)
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .scale({ x: this.callButtonPressed ? 0.9 : 1.0, y: this.callButtonPressed ? 0.9 : 1.0 })
        .animation({ duration: 150, curve: Curve.EaseInOut })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.callButtonPressed = true;
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.callButtonPressed = false;
          }
        })
        .onClick(() => {
          this.showContactAlert = true;
        })

        // 发送消息按钮
        Column() {
          Text('💬')
            .fontSize(18)
          Text('消息')
            .fontSize(11)
            .fontColor(ColorConstants.IOS_BLUE)
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .scale({ x: this.msgButtonPressed ? 0.9 : 1.0, y: this.msgButtonPressed ? 0.9 : 1.0 })
        .animation({ duration: 150, curve: Curve.EaseInOut })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.msgButtonPressed = true;
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.msgButtonPressed = false;
          }
        })
        .onClick(() => {
          CommonUtil.copyToClipboard(this.item?.contact || '');
        })

        // 认领/完成按钮
        Text(this.item?.status === 'completed' ? '已完成'
          : (this.item?.type === 'lost' ? '我捡到了' : '认领物品'))
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .layoutWeight(2)
          .height(44)
          .textAlign(TextAlign.Center)
          .backgroundColor(this.item?.status === 'completed'
            ? ColorConstants.TEXT_TERTIARY
            : ColorConstants.IOS_BLUE)
          .borderRadius(22)
          .margin({ left: 8 })
          .scale({ x: this.completeButtonPressed ? 0.97 : 1.0, y: this.completeButtonPressed ? 0.97 : 1.0 })
          .opacity(this.completeButtonPressed ? 0.8 : 1.0)
          .animation({ duration: 150, curve: Curve.EaseInOut })
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down && this.item?.status !== 'completed') {
              this.completeButtonPressed = true;
            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
              this.completeButtonPressed = false;
            }
          })
          .onClick(() => {
            if (this.item?.status !== 'completed') {
              this.showCompleteAlert = true;
            }
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    }
    .width('100%')
    .backgroundColor('rgba(248, 248, 248, 0.92)')
    .border({
      width: { top: 0.5 },
      color: 'rgba(0, 0, 0, 0.1)'
    })
    .position({ x: 0, y: '100%' })
    .translate({ x: 0, y: '-100%' })
    .zIndex(5)
  }

  build() {
    Stack() {
      if (this.item) {
        Scroll() {
          Column() {
            // 顶部大图区域
            this.HeroSection()

            // 标题卡片（上浮效果）
            this.TitleSection()

            // 信息卡片
            this.InfoCard()

            // 描述卡片
            this.DescriptionCard()
          }
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .onScroll((scrollOffset: number, scrollState: ScrollState) => {
          this.onScrollUpdate(scrollOffset);
        })
      }

      // 导航栏（叠在顶部）
      this.NavBar()

      // 底部操作栏
      this.BottomActionBar()

      // 联系确认弹窗
      if (this.showContactAlert) {
        this.iOSAlert(
          '拨打电话',
          `确定要拨打 ${this.item?.contact || ''} 吗？`,
          '取消',
          '拨打',
          ColorConstants.IOS_BLUE,
          () => {
            CommonUtil.showToast('正在拨打：' + this.item?.contact);
          }
        )
      }

      // 完成确认弹窗
      if (this.showCompleteAlert) {
        this.iOSAlert(
          this.item?.type === 'lost' ? '确认捡到' : '确认认领',
          this.item?.type === 'lost'
            ? '确认您已捡到该物品，请尽快联系失主归还。'
            : '确认您是物品的失主，请联系对方领取。',
          '取消',
          '确认',
          ColorConstants.IOS_GREEN,
          () => {
            CommonUtil.showToast('操作成功');
          }
        )
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }
}
