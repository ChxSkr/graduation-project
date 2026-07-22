import { CardInfo } from '../../model/CampusCard';
import { UserInfo } from '../../model/User';
import { ColorConstants } from '../../constant/ColorConstants';
import { CommonUtil } from '../../utils/CommonUtil';

@Component
export struct HeroCampusCard {
  cardInfo: CardInfo | null = null;
  userInfo: UserInfo | null = null;
  schoolName: string = '华夏科技大学';

  private get majorInfo(): string {
    if (!this.userInfo) return '---';
    const parts: string[] = [];
    if (this.userInfo.major) parts.push(this.userInfo.major);
    if (this.userInfo.grade) parts.push(this.userInfo.grade);
    return parts.join(' · ') || '---';
  }

  @State floatOffsetY: number = 0;
  @State isAnimating: boolean = false;

  onRechargeClick?: () => void;
  onBillClick?: () => void;
  onLostClick?: () => void;
  onQrClick?: () => void;

  aboutToAppear(): void {
    this.startFloatAnimation();
  }

  aboutToDisappear(): void {
    this.isAnimating = false;
  }

  // 浮动动画（轻微上下浮动）
  private startFloatAnimation(): void {
    this.isAnimating = true;
    animateTo({
      duration: 2800,
      curve: Curve.EaseInOut,
      iterations: -1,
      playMode: PlayMode.Alternate
    }, () => {
      this.floatOffsetY = 4;
    });
  }

  // 获取状态文本
  private getStatusText(): string {
    if (!this.cardInfo) return '未激活';
    switch (this.cardInfo.status) {
      case 'normal': return '正常';
      case 'frozen': return '已冻结';
      case 'lost': return '已挂失';
      default: return '未知';
    }
  }

  // 获取状态颜色
  private getStatusColor(): string {
    if (!this.cardInfo) return '#FF6B6B';
    switch (this.cardInfo.status) {
      case 'normal': return ColorConstants.SUCCESS;
      case 'frozen': return '#FFB454';
      case 'lost': return '#FF6B6B';
      default: return '#9AA4BD';
    }
  }

  build() {
    Column() {
      // 顶部：学校标识 + 状态徽章
      Row() {
        Row({ space: 6 }) {
          Text('🎓')
            .fontSize(14)
          Text(this.schoolName)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('rgba(255, 255, 255, 0.85)')
            .letterSpacing(0.5)
        }
        .layoutWeight(1)

        // 状态徽章
        Row({ space: 4 }) {
          Circle()
            .width(6)
            .height(6)
            .fill(this.getStatusColor())
          Text(this.getStatusText())
            .fontSize(11)
            .fontColor('rgba(255, 255, 255, 0.9)')
        }
        .padding({ left: 10, right: 10, top: 5, bottom: 5 })
        .borderRadius(12)
        .backgroundColor('rgba(255, 255, 255, 0.18)')
      }
      .width('100%')

      // 中部主信息：左侧姓名卡号 + 右侧余额
      Row() {
        // 左侧：姓名 + 专业 + 卡号
        Column({ space: 6 }) {
          Text(this.cardInfo ? this.cardInfo.userName : '---')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .letterSpacing(1)

          Text(this.majorInfo)
            .fontSize(11)
            .fontColor('rgba(255, 255, 255, 0.6)')

          Row({ space: 6 }) {
            Text('卡号')
              .fontSize(10)
              .fontColor('rgba(255, 255, 255, 0.5)')
            Text(this.cardInfo ? CommonUtil.maskCardNo(this.cardInfo.cardNo) : '****')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor('rgba(255, 255, 255, 0.85)')
          }
          .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 右侧：余额突出展示
        Column() {
          Text('余额')
            .fontSize(11)
            .fontColor('rgba(255, 255, 255, 0.65)')
            .letterSpacing(1)

          Row({ space: 2 }) {
            Text('¥')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('rgba(255, 255, 255, 0.85)')
              .margin({ top: 8 })

            Text(this.cardInfo ? CommonUtil.formatMoney(this.cardInfo.balance) : '0.00')
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .letterSpacing(-0.5)
          }
          .alignItems(VerticalAlign.Bottom)

          Text('CNY')
            .fontSize(9)
            .fontColor('rgba(255, 255, 255, 0.45)')
            .letterSpacing(2)
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .margin({ top: 20, bottom: 20 })
      .alignItems(VerticalAlign.Center)

      // 底部操作区：三栏毛玻璃按钮
      Row() {
        this.ActionButton('＋', '充值', this.onRechargeClick)
        this.ActionDivider()
        this.ActionButton('≡', '账单', this.onBillClick)
        this.ActionDivider()
        this.ActionButton('✕', '挂失', this.onLostClick)
      }
      .width('100%')
      .padding({ top: 14, bottom: 14 })
      .borderRadius(16)
      .backgroundColor('rgba(255, 255, 255, 0.12)')
      .backdropBlur(10)
    }
    .width('100%')
    .padding(20)
    .borderRadius(24)
    .linearGradient({
      direction: GradientDirection.LeftBottom,
      colors: [
        [ColorConstants.PRIMARY_DEEP, 0.0],
        [ColorConstants.PRIMARY, 0.5],
        [ColorConstants.TEAL, 1.0]
      ]
    })
    .shadow({
      radius: 24,
      color: 'rgba(10, 89, 247, 0.28)',
      offsetX: 0,
      offsetY: 10
    })
    .translate({ y: this.floatOffsetY })
  }

  // 操作按钮
  @Builder
  ActionButton(icon: string, label: string, onClick?: () => void) {
    Column({ space: 4 }) {
      Text(icon)
        .fontSize(18)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Medium)
      Text(label)
        .fontSize(11)
        .fontColor('rgba(255, 255, 255, 0.9)')
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => onClick?.())
  }

  // 分隔线
  @Builder
  ActionDivider() {
    Column()
      .width(0.5)
      .height(24)
      .backgroundColor('rgba(255, 255, 255, 0.2)')
  }
}
