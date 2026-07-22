import { CardViewModel, MonthlySummary } from '../../viewmodel/CardViewModel';
import { BalanceCard } from '../../components/card/BalanceCard';
import { RecordItem } from '../../components/card/RecordItem';
import { ConsumptionRecord } from '../../model/CampusCard';
import { ColorConstants } from '../../constant/ColorConstants';
import { CommonUtil } from '../../utils/CommonUtil';
import router from '@ohos.router';

// iOS 风格确认对话框
@CustomDialog
struct ConfirmDialog {
  controller: CustomDialogController;
  title: string = '';
  message: string = '';
  confirmText: string = '确定';
  cancelText: string = '取消';
  confirmColor: string = ColorConstants.IOS_BLUE;
  onConfirm: () => void = () => {};

  build() {
    Column() {
      Text(this.title)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(ColorConstants.TEXT_PRIMARY)
        .margin({ top: 20, bottom: 6 })

      Text(this.message)
        .fontSize(13)
        .fontColor(ColorConstants.TEXT_SECONDARY)
        .textAlign(TextAlign.Center)
        .margin({ left: 16, right: 16, bottom: 20 })

      Divider()
        .color(ColorConstants.DIVIDER)
        .strokeWidth(0.5)

      Row() {
        Text(this.cancelText)
          .fontSize(17)
          .fontColor(ColorConstants.IOS_BLUE)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .height(44)
          .onClick(() => {
            this.controller.close();
          })

        Divider()
          .color(ColorConstants.DIVIDER)
          .strokeWidth(0.5)
          .vertical(true)
          .height(44)

        Text(this.confirmText)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.confirmColor)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .height(44)
          .onClick(() => {
            this.onConfirm();
            this.controller.close();
          })
      }
      .width('100%')
    }
    .width('78%')
    .backgroundColor(ColorConstants.BG_CARD)
    .borderRadius(14)
    .clip(true)
  }
}

// 快捷功能项配置
interface QuickFuncItem {
  icon: string;
  label: string;
  bgColor: string;
  action: () => void;
}

@Entry
@Component
export struct CardPage {
  @State viewModel: CardViewModel = new CardViewModel();
  @State cardAppear: boolean = false;
  @State displayBalance: number = 0;
  @State isRefreshing: boolean = false;
  @State funcClickIndex: number = -1;

  private lostDialogController: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      title: '挂失确认',
      message: '确定要挂失校园卡吗？挂失后卡片将无法使用，请谨慎操作。',
      confirmText: '确认挂失',
      confirmColor: ColorConstants.IOS_RED,
      onConfirm: async () => {
        const success = await this.viewModel.toggleLostStatus();
        if (success) {
          CommonUtil.showToast('挂失成功');
        } else {
          CommonUtil.showToast('操作失败');
        }
      }
    }),
    alignment: DialogAlignment.Center,
    customStyle: true
  });

  private unlostDialogController: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      title: '解挂确认',
      message: '确定要解除卡片挂失吗？解除后卡片可恢复正常使用。',
      confirmText: '确认解挂',
      confirmColor: ColorConstants.IOS_BLUE,
      onConfirm: async () => {
        const success = await this.viewModel.toggleLostStatus();
        if (success) {
          CommonUtil.showToast('解挂成功');
        } else {
          CommonUtil.showToast('操作失败');
        }
      }
    }),
    alignment: DialogAlignment.Center,
    customStyle: true
  });

  aboutToAppear(): void {
    this.refreshData();
    // 卡片滑入动画
    animateTo({ duration: 600, curve: Curve.EaseOut, delay: 100 }, () => {
      this.cardAppear = true;
    });
    // 余额数字滚动动画
    this.animateBalance();
  }

  private async refreshData(): Promise<void> {
    await this.viewModel.loadCardInfo();
    await this.viewModel.loadRecords();
    this.animateBalance();
  }

  private animateBalance(): void {
    const targetBalance = this.viewModel.cardInfo?.balance ?? 0;
    this.displayBalance = 0;
    const duration = 800;
    const startTime = Date.now();
    const startValue = 0;
    const endValue = targetBalance;

    const timer = setInterval(() => {
      const elapsed = Date.now() - startTime;
      if (elapsed >= duration) {
        this.displayBalance = endValue;
        clearInterval(timer);
      } else {
        const progress = elapsed / duration;
        // easeOutQuart 缓动函数
        const easeProgress = 1 - Math.pow(1 - progress, 4);
        this.displayBalance = startValue + (endValue - startValue) * easeProgress;
      }
    }, 16);
  }

  aboutToReappear(): void {
    this.refreshData();
  }

  // 下拉刷新处理
  private async onRefresh(): Promise<void> {
    if (this.isRefreshing) return;
    this.isRefreshing = true;
    try {
      await this.viewModel.loadCardInfo();
      await this.viewModel.loadRecords();
      this.animateBalance();
      CommonUtil.showToast('刷新成功');
    } finally {
      this.isRefreshing = false;
    }
  }

  // 获取快捷功能列表
  private getQuickFuncs(): QuickFuncItem[] {
    const isLost = this.viewModel.cardInfo?.status === 'lost';
    return [
      {
        icon: '💰',
        label: '充值',
        bgColor: 'rgba(0, 122, 255, 0.12)',
        action: () => {
          if (isLost) {
            CommonUtil.showToast('卡片已挂失，无法充值');
          } else {
            router.pushUrl({ url: 'pages/card/RechargePage' });
          }
        }
      },
      {
        icon: '📋',
        label: '消费记录',
        bgColor: 'rgba(88, 86, 214, 0.12)',
        action: () => { router.pushUrl({ url: 'pages/card/RecordPage' }); }
      },
      {
        icon: isLost ? '🔓' : '🔒',
        label: isLost ? '解挂' : '挂失',
        bgColor: isLost ? 'rgba(52, 199, 89, 0.12)' : 'rgba(255, 59, 48, 0.12)',
        action: () => {
          if (isLost) {
            this.unlostDialogController.open();
          } else {
            this.lostDialogController.open();
          }
        }
      },
      {
        icon: '📊',
        label: '账单明细',
        bgColor: 'rgba(255, 149, 0, 0.12)',
        action: () => { router.pushUrl({ url: 'pages/card/RecordPage' }); }
      },
      {
        icon: '📱',
        label: '校园码',
        bgColor: 'rgba(175, 82, 222, 0.12)',
        action: () => { CommonUtil.showToast('校园码'); }
      }
    ];
  }

  @Builder
  FuncButton(item: QuickFuncItem, index: number) {
    Column() {
      Column() {
        Text(item.icon)
          .fontSize(22)
      }
      .width(52)
      .height(52)
      .borderRadius(16)
      .backgroundColor(item.bgColor)
      .justifyContent(FlexAlign.Center)
      .scale({ x: this.funcClickIndex === index ? 0.9 : 1, y: this.funcClickIndex === index ? 0.9 : 1 })
      .animation({ duration: 150, curve: Curve.EaseInOut })

      Text(item.label)
        .fontSize(12)
        .fontColor(ColorConstants.TEXT_PRIMARY)
        .margin({ top: 8 })
    }
    .width('20%')
    .padding({ top: 8, bottom: 8 })
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      // 点击缩放反馈
      this.funcClickIndex = index;
      setTimeout(() => {
        this.funcClickIndex = -1;
      }, 150);
      item.action();
    })
  }

  @Builder
  NavBar() {
    Row() {
      Text('校园卡')
        .fontSize(34)
        .fontWeight(FontWeight.Bold)
        .fontColor(ColorConstants.TEXT_PRIMARY)
        .layoutWeight(1)
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 8, bottom: 12 })
    .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
    .backgroundColor(ColorConstants.NAV_BAR_BG)
  }

  @Builder
  SectionHeader(title: string, actionLabel?: string, onAction?: () => void) {
    Row() {
      Text(title)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(ColorConstants.TEXT_PRIMARY)
        .layoutWeight(1)

      if (actionLabel && onAction) {
        Text(actionLabel)
          .fontSize(15)
          .fontWeight(FontWeight.Regular)
          .fontColor(ColorConstants.IOS_BLUE)
          .onClick(() => onAction())
      }
    }
    .width('100%')
    .padding({ left: 4, bottom: 10, top: 8 })
  }

  @Builder
  MonthGroup(month: string, records: ConsumptionRecord[]) {
    Column() {
      // 月份标题 + 本月汇总
      Row() {
        Text(month)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(ColorConstants.TEXT_SECONDARY)
          .layoutWeight(1)

        Text('本月支出 ¥' + this.viewModel.getMonthlySummary(month).totalConsume.toFixed(2))
          .fontSize(12)
          .fontColor(ColorConstants.TEXT_TERTIARY)
      }
      .width('100%')
      .padding({ top: 4, bottom: 8, left: 4, right: 4 })

      // 记录列表卡片
      Column() {
        ForEach(records.slice(0, 5), (record: ConsumptionRecord, index: number) => {
          RecordItem({ record: record })
            .padding({ left: 16, right: 16 })

          if (index < Math.min(records.length, 5) - 1) {
            Divider()
              .color(ColorConstants.DIVIDER)
              .strokeWidth(0.5)
              .margin({ left: 64 })
          }
        }, (record: ConsumptionRecord) => record.id)
      }
      .width('100%')
      .backgroundColor(ColorConstants.BG_CARD)
      .borderRadius(14)
      .clip(true)
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  @Builder
  EmptyState() {
    Column() {
      Text('📭')
        .fontSize(48)
        .margin({ bottom: 12 })

      Text('暂无消费记录')
        .fontSize(16)
        .fontColor(ColorConstants.TEXT_SECONDARY)
        .margin({ bottom: 6 })

      Text('使用校园卡消费后会在这里显示')
        .fontSize(13)
        .fontColor(ColorConstants.TEXT_TERTIARY)
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(ColorConstants.BG_CARD)
    .borderRadius(14)
  }

  @Builder
  RechargeButton() {
    Text('立即充值')
      .fontSize(17)
      .fontWeight(FontWeight.Medium)
      .fontColor('#FFFFFF')
      .width('100%')
      .height(50)
      .textAlign(TextAlign.Center)
      .backgroundColor(this.viewModel.cardInfo?.status === 'lost'
        ? ColorConstants.TEXT_TERTIARY
        : ColorConstants.IOS_BLUE)
      .borderRadius(14)
      .enabled(this.viewModel.cardInfo?.status !== 'lost')
      .onClick(() => {
        if (this.viewModel.cardInfo?.status === 'lost') {
          CommonUtil.showToast('卡片已挂失，无法充值');
        } else {
          router.pushUrl({ url: 'pages/card/RechargePage' });
        }
      })
  }

  @Builder
  BalanceCardWithAnim() {
    Column() {
      if (this.viewModel.cardInfo) {
        // 卡片顶部：卡类型标识 + 状态
        Row() {
          Row() {
            Text('💳')
              .fontSize(20)
            Text('校园卡')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .margin({ left: 6 })
          }
          .layoutWeight(1)

          Text(this.viewModel.cardInfo.status === 'normal' ? '正常' : '已挂失')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .backgroundColor(this.viewModel.cardInfo.status === 'normal'
              ? 'rgba(52, 199, 89, 0.8)'
              : 'rgba(255, 59, 48, 0.8)')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .borderRadius(10)
        }
        .width('100%')

        // 余额区域
        Column() {
          Text('余额')
            .fontSize(14)
            .fontColor('rgba(255, 255, 255, 0.7)')
            .letterSpacing(0.5)

          Row() {
            Text('¥')
              .fontSize(20)
              .fontWeight(FontWeight.Regular)
              .fontColor('rgba(255, 255, 255, 0.9)')
              .margin({ top: 12 })

            Text(CommonUtil.formatMoney(this.displayBalance))
              .fontSize(40)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .letterSpacing(-0.5)
              .margin({ left: 2, top: 12 })
          }
          .alignItems(VerticalAlign.Bottom)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ top: 24, bottom: 28 })

        // 底部信息：卡号 + 持卡人
        Row() {
          Column() {
            Text('卡号')
              .fontSize(11)
              .fontColor('rgba(255, 255, 255, 0.55)')
            Text(CommonUtil.maskCardNo(this.viewModel.cardInfo.cardNo))
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('rgba(255, 255, 255, 0.95)')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Column() {
            Text('持卡人')
              .fontSize(11)
              .fontColor('rgba(255, 255, 255, 0.55)')
            Text(this.viewModel.cardInfo.userName)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('rgba(255, 255, 255, 0.95)')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.End)
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(24)
    .borderRadius(20)
    .linearGradient({
      direction: GradientDirection.LeftTop,
      colors: this.viewModel.cardInfo?.status === 'lost'
        ? [
          ['#8E8E93', 0.0],
          ['#636366', 0.5],
          ['#48484A', 1.0]
        ]
        : [
          ['#0A84FF', 0.0],
          [ColorConstants.IOS_BLUE, 0.5],
          ['#0040DD', 1.0]
        ]
    })
    .shadow({
      radius: 16,
      color: this.viewModel.cardInfo?.status === 'lost'
        ? 'rgba(142, 142, 147, 0.3)'
        : 'rgba(0, 122, 255, 0.3)',
      offsetX: 0,
      offsetY: 8
    })
    // 卡片滑入+渐显动画
    .opacity(this.cardAppear ? 1 : 0)
    .translate({ y: this.cardAppear ? 0 : 30 })
    .animation({ duration: 600, curve: Curve.EaseOut })
  }

  build() {
    Column() {
      // 顶部导航栏 - iOS大标题风格
      this.NavBar()

      // 下拉刷新 + 滚动内容
      Refresh({ refreshing: $$this.isRefreshing }) {
        Scroll() {
          Column() {
            // 余额卡片（带动画）
            Column() {
              this.BalanceCardWithAnim()
            }
            .margin({ bottom: 28 })

            // 充值按钮
            Column() {
              this.RechargeButton()
            }
            .margin({ bottom: 32 })

            // 功能按钮区
            this.SectionHeader('快捷功能')

            Row() {
              ForEach(this.getQuickFuncs(), (item: QuickFuncItem, index: number) => {
                this.FuncButton(item, index)
              }, (item: QuickFuncItem, index: number) => item.label + index)
            }
            .width('100%')
            .padding({ top: 10, bottom: 10 })
            .backgroundColor(ColorConstants.BG_CARD)
            .borderRadius(14)
            .margin({ bottom: 32 })

            // 最近消费（按月分组）
            this.SectionHeader('最近消费', '查看全部', () => {
              router.pushUrl({ url: 'pages/card/RecordPage' });
            })

            if (this.viewModel.records.length === 0) {
              this.EmptyState()
            } else {
              // 按月分组展示
              ForEach(Array.from(this.viewModel.getRecordsByMonth().keys()), (month: string) => {
                this.MonthGroup(month, this.viewModel.getRecordsByMonth().get(month) || [])
              }, (month: string) => month)
            }
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 24, top: 4 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .layoutWeight(1)
      .onRefreshing(() => {
        this.onRefresh();
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }
}
