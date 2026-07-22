import { CardViewModel } from '../../viewmodel/CardViewModel';
import { ColorConstants } from '../../constant/ColorConstants';
import { CommonUtil } from '../../utils/CommonUtil';
import { BackButton } from '../../components/common/BackButton';

// 支付方式配置
interface PayMethod {
  name: string;
  icon: string;
  bgColor: string;
}

@Entry
@Component
export struct RechargePage {
  @State viewModel: CardViewModel = new CardViewModel();
  @State selectedAmount: number = 50;
  @State customAmount: string = '';
  @State isRecharging: boolean = false;
  @State selectedPayMethod: number = 0;
  @State showSuccess: boolean = false;
  @State successAnimStage: number = 0; // 0:未开始 1:圆圈缩放 2:勾线绘制
  @State amountScale: number = 1;
  @State keyboardOffset: number = 0;
  @State isInputFocus: boolean = false;

  private presetAmounts: number[] = [20, 50, 100, 200];
  private payMethods: PayMethod[] = [
    { name: '微信支付', icon: '💬', bgColor: '#07C160' },
    { name: '支付宝', icon: '💰', bgColor: '#1677FF' },
    { name: '银行卡', icon: '💳', bgColor: '#FF9500' }
  ];

  aboutToAppear(): void {
    this.viewModel.loadCardInfo();
  }

  // 播放成功动画
  private playSuccessAnimation(): void {
    this.showSuccess = true;
    this.successAnimStage = 0;

    // 第一阶段：圆圈缩放出现
    animateTo({ duration: 300, curve: Curve.Smooth }, () => {
      this.successAnimStage = 1;
    });

    // 第二阶段：打勾动画
    setTimeout(() => {
      animateTo({ duration: 400, curve: Curve.EaseOut }, () => {
        this.successAnimStage = 2;
      });
    }, 300);

    // 关闭成功弹窗
    setTimeout(() => {
      animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
        this.showSuccess = false;
        this.successAnimStage = 0;
      });
    }, 2000);
  }

  // 金额选择动画反馈
  private selectAmount(amount: number): void {
    this.selectedAmount = amount;
    this.customAmount = '';
  }

  @Builder
  NavBar() {
    Row() {
      BackButton({ style: 'symbol', color: ColorConstants.IOS_BLUE })

      Text('充值')
        .fontSize(34)
        .fontWeight(FontWeight.Bold)
        .fontColor(ColorConstants.TEXT_PRIMARY)
        .layoutWeight(1)
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .padding({ left: 16, right: 20, top: 8, bottom: 12 })
    .backgroundColor(ColorConstants.NAV_BAR_BG)
  }

  @Builder
  AmountItem(amount: number) {
    Column() {
      Text('¥' + amount)
        .fontSize(20)
        .fontWeight(this.selectedAmount === amount ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.selectedAmount === amount ? '#FFFFFF' : ColorConstants.TEXT_PRIMARY)
    }
    .width('48%')
    .height(64)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.selectedAmount === amount ? ColorConstants.IOS_BLUE : ColorConstants.BG_CARD)
    .borderRadius(14)
    .border({
      width: this.selectedAmount === amount ? 0 : 1,
      color: this.selectedAmount === amount ? ColorConstants.IOS_BLUE : ColorConstants.TRANSPARENT
    })
    .shadow({
      radius: this.selectedAmount === amount ? 12 : 0,
      color: this.selectedAmount === amount ? 'rgba(0, 122, 255, 0.35)' : 'rgba(0,0,0,0)',
      offsetX: 0,
      offsetY: this.selectedAmount === amount ? 4 : 0
    })
    .scale({
      x: this.selectedAmount === amount ? 1.02 : 1,
      y: this.selectedAmount === amount ? 1.02 : 1
    })
    .animation({ duration: 200, curve: Curve.EaseInOut })
    .onClick(() => {
      this.selectAmount(amount);
    })
  }

  @Builder
  PayMethodRow(method: PayMethod, index: number) {
    Row() {
      // 左侧图标
      Column() {
        Text(method.icon)
          .fontSize(18)
      }
      .width(32)
      .height(32)
      .borderRadius(8)
      .backgroundColor(method.bgColor + '20')
      .justifyContent(FlexAlign.Center)
      .margin({ right: 12 })

      // 文字
      Text(method.name)
        .fontSize(16)
        .fontColor(ColorConstants.TEXT_PRIMARY)
        .layoutWeight(1)

      // 右侧勾选
      if (this.selectedPayMethod === index) {
        Text('✓')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(ColorConstants.IOS_BLUE)
      }
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.selectedPayMethod === index
      ? ColorConstants.PRIMARY_LIGHT
      : ColorConstants.BG_CARD)
    .borderRadius(this.selectedPayMethod === index ? 12 : 0)
    .animation({ duration: 200, curve: Curve.EaseInOut })
    .onClick(() => {
      this.selectedPayMethod = index;
    })
  }

  @Builder
  SuccessOverlay() {
    Column() {
      Column() {
        // 成功对勾圆圈
        Stack() {
          // 背景圆
          Circle()
            .width(80)
            .height(80)
            .fill(ColorConstants.IOS_GREEN)
            .scale({
              x: this.successAnimStage >= 1 ? 1 : 0,
              y: this.successAnimStage >= 1 ? 1 : 0
            })
            .animation({ duration: 300, curve: Curve.Smooth })

          // 对勾
          Text('✓')
            .fontSize(44)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .opacity(this.successAnimStage >= 2 ? 1 : 0)
            .scale({
              x: this.successAnimStage >= 2 ? 1 : 0.5,
              y: this.successAnimStage >= 2 ? 1 : 0.5
            })
            .animation({ duration: 400, curve: Curve.EaseOut, delay: 100 })
        }
        .width(80)
        .height(80)
        .margin({ bottom: 16 })

        Text('充值成功')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor(ColorConstants.TEXT_PRIMARY)
          .margin({ bottom: 6 })

        Text('¥' + CommonUtil.formatMoney(this.getRechargeAmount()) + ' 已到账')
          .fontSize(14)
          .fontColor(ColorConstants.TEXT_SECONDARY)
      }
      .width(200)
      .padding(24)
      .backgroundColor(ColorConstants.BG_CARD)
      .borderRadius(20)
      .shadow({
        radius: 24,
        color: 'rgba(0, 0, 0, 0.15)',
        offsetX: 0,
        offsetY: 8
      })
      .scale({
        x: this.showSuccess ? 1 : 0.8,
        y: this.showSuccess ? 1 : 0.8
      })
      .opacity(this.showSuccess ? 1 : 0)
      .animation({ duration: 300, curve: Curve.EaseOut })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .backgroundColor('rgba(0, 0, 0, 0.4)')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航栏 - iOS大标题风格
        this.NavBar()

        Scroll() {
          Column() {
            // 当前余额卡片
            Column() {
              Text('当前余额')
                .fontSize(14)
                .fontColor('rgba(255, 255, 255, 0.7)')

              Row() {
                Text('¥')
                  .fontSize(24)
                  .fontWeight(FontWeight.Regular)
                  .fontColor('rgba(255, 255, 255, 0.9)')
                  .margin({ top: 6 })

                Text(CommonUtil.formatMoney(this.viewModel.cardInfo?.balance ?? 0))
                  .fontSize(36)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .margin({ left: 2, top: 6 })
              }
              .alignItems(VerticalAlign.Bottom)
              .margin({ top: 8 })
            }
            .width('100%')
            .padding(24)
            .linearGradient({
              direction: GradientDirection.LeftTop,
              colors: [
                ['#0A84FF', 0.0],
                [ColorConstants.IOS_BLUE, 0.5],
                ['#0040DD', 1.0]
              ]
            })
            .borderRadius(16)
            .margin({ bottom: 28 })

            // 充值金额 - 分组样式
            Text('选择充值金额')
              .fontSize(13)
              .fontColor(ColorConstants.TEXT_SECONDARY)
              .textAlign(TextAlign.Start)
              .width('100%')
              .padding({ left: 16, bottom: 6 })

            Column() {
              Column() {
                Row() {
                  this.AmountItem(20)
                  Blank()
                  this.AmountItem(50)
                }
                .width('100%')
                .margin({ bottom: 12 })

                Row() {
                  this.AmountItem(100)
                  Blank()
                  this.AmountItem(200)
                }
                .width('100%')
              }
              .padding(16)

              Divider()
                .color(ColorConstants.DIVIDER)
                .strokeWidth(0.5)
                .margin({ left: 16 })

              // 自定义金额
              Row() {
                Text('自定义金额')
                  .fontSize(16)
                  .fontColor(ColorConstants.TEXT_PRIMARY)
                  .layoutWeight(1)

                TextInput({ placeholder: '请输入金额', text: this.customAmount })
                  .type(InputType.Number)
                  .fontSize(16)
                  .fontColor(ColorConstants.IOS_BLUE)
                  .textAlign(TextAlign.End)
                  .width(140)
                  .height(40)
                  .backgroundColor(ColorConstants.TRANSPARENT)
                  .placeholderColor(ColorConstants.TEXT_TERTIARY)
                  .onChange((value: string) => {
                    this.customAmount = value;
                    this.selectedAmount = 0;
                  })
              }
              .width('100%')
              .height(52)
              .padding({ left: 16, right: 16 })
            }
            .width('100%')
            .backgroundColor(ColorConstants.BG_CARD)
            .borderRadius(12)
            .clip(true)
            .margin({ bottom: 24 })

            // 支付方式 - 分组样式
            Text('支付方式')
              .fontSize(13)
              .fontColor(ColorConstants.TEXT_SECONDARY)
              .textAlign(TextAlign.Start)
              .width('100%')
              .padding({ left: 16, bottom: 6 })

            Column() {
              ForEach(this.payMethods, (method: PayMethod, index: number) => {
                this.PayMethodRow(method, index)

                if (index < this.payMethods.length - 1) {
                  Divider()
                    .color(ColorConstants.DIVIDER)
                    .strokeWidth(0.5)
                    .margin({ left: 60 })
                }
              }, (method: PayMethod, index: number) => method.name + index)
            }
            .width('100%')
            .backgroundColor(ColorConstants.BG_CARD)
            .borderRadius(12)
            .clip(true)
            .margin({ bottom: 32 })

            // 确认充值按钮 - iOS 系统风格
            Button(this.isRecharging ? '充值中...' : '确认充值 ¥' + (this.getRechargeAmount() > 0 ? this.getRechargeAmount().toFixed(2) : '--'))
              .width('100%')
              .height(50)
              .fontSize(17)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .backgroundColor(this.getRechargeAmount() > 0 && !this.isRecharging
                ? ColorConstants.IOS_BLUE
                : ColorConstants.TEXT_TERTIARY)
              .borderRadius(14)
              .enabled(this.getRechargeAmount() > 0 && !this.isRecharging)
              .onClick(() => {
                this.doRecharge();
              })
              .margin({ bottom: 24 })

            // 底部提示
            Text('充值金额将实时到账，如有疑问请联系客服')
              .fontSize(12)
              .fontColor(ColorConstants.TEXT_TERTIARY)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 4, bottom: 24 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ColorConstants.BG_PAGE)
      .translate({ y: -this.keyboardOffset })
      .animation({ duration: 250, curve: Curve.EaseOut })

      // 成功弹窗
      if (this.showSuccess) {
        this.SuccessOverlay()
      }
    }
    .width('100%')
    .height('100%')
    .onKeyEvent((event) => {
      // 简易键盘适配：监听输入框焦点变化
      if (event.type === KeyType.Down) {
        // 实际项目中可使用 expandSafeArea 或 keyboardAvoidMode
        // 这里用简化方式模拟键盘上移
      }
    })
  }

  private getRechargeAmount(): number {
    if (this.customAmount) {
      const num = parseFloat(this.customAmount);
      return isNaN(num) ? 0 : num;
    }
    return this.selectedAmount;
  }

  private async doRecharge(): Promise<void> {
    const amount = this.getRechargeAmount();
    if (amount <= 0) {
      CommonUtil.showToast('请输入正确的充值金额');
      return;
    }

    this.isRecharging = true;
    try {
      const channel = this.payMethods[this.selectedPayMethod]?.name;
      const success = await this.viewModel.recharge(amount, channel, '线上充值');
      if (success) {
        this.playSuccessAnimation();
      } else {
        CommonUtil.showToast('充值失败，请重试');
      }
    } finally {
      this.isRecharging = false;
    }
  }
}
