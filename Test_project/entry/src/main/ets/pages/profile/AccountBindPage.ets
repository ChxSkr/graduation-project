import { ColorConstants } from '../../constant/ColorConstants';
import { CommonUtil } from '../../utils/CommonUtil';
import { BackButton } from '../../components/common/BackButton';
import promptAction from '@ohos.promptAction';

// 账号绑定状态接口
interface BindStatus {
  wechat: boolean;
  qq: boolean;
  email: boolean;
  phone: boolean;
}

@Entry
@Component
struct AccountBindPage {
  @StorageLink('darkMode') isDarkMode: boolean = false;
  @StorageLink('studentId') studentId: string = '';
  
  // 绑定状态
  @State bindStatus: BindStatus = {
    wechat: false,
    qq: false,
    email: false,
    phone: false
  };
  
  // 绑定信息
  @State wechatAccount: string = '';
  @State qqAccount: string = '';
  @State emailAccount: string = '';
  @State phoneAccount: string = '';
  
  // 弹窗状态
  @State showBindDialog: boolean = false;
  @State currentBindType: string = '';
  @State inputAccount: string = '';
  @State inputCode: string = '';
  
  aboutToAppear(): void {
    // 从AppStorage加载绑定状态
    this.loadBindStatus();
  }
  
  // 加载绑定状态
  private loadBindStatus(): void {
    const savedStatus = AppStorage.get<BindStatus>('bindStatus');
    if (savedStatus) {
      this.bindStatus = savedStatus;
    }
    
    // 加载绑定账号信息
    this.wechatAccount = AppStorage.get<string>('wechatAccount') || '';
    this.qqAccount = AppStorage.get<string>('qqAccount') || '';
    this.emailAccount = AppStorage.get<string>('emailAccount') || '';
    this.phoneAccount = AppStorage.get<string>('phoneAccount') || '';
  }
  
  // 保存绑定状态
  private saveBindStatus(): void {
    AppStorage.setOrCreate('bindStatus', this.bindStatus);
    AppStorage.setOrCreate('wechatAccount', this.wechatAccount);
    AppStorage.setOrCreate('qqAccount', this.qqAccount);
    AppStorage.setOrCreate('emailAccount', this.emailAccount);
    AppStorage.setOrCreate('phoneAccount', this.phoneAccount);
  }
  
  // 计算属性：根据深色模式返回对应颜色
  private getTextPrimary(): string {
    return this.isDarkMode ? ColorConstants.DARK_TEXT_PRIMARY : ColorConstants.TEXT_PRIMARY;
  }
  
  private getTextSecondary(): string {
    return this.isDarkMode ? ColorConstants.DARK_TEXT_SECONDARY : ColorConstants.TEXT_SECONDARY;
  }
  
  private getTextTertiary(): string {
    return this.isDarkMode ? ColorConstants.DARK_TEXT_TERTIARY : ColorConstants.TEXT_TERTIARY;
  }
  
  private getBgColor(): string {
    return this.isDarkMode ? ColorConstants.DARK_BG_PAGE : ColorConstants.BG_PAGE;
  }
  
  private getBgCard(): string {
    return this.isDarkMode ? ColorConstants.DARK_BG_CARD : ColorConstants.BG_CARD;
  }
  
  private getDividerColor(): string {
    return this.isDarkMode ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.05)';
  }
  
  // 处理绑定操作
  private handleBind(type: string): void {
    this.currentBindType = type;
    this.inputAccount = '';
    this.inputCode = '';
    this.showBindDialog = true;
  }
  
  // 处理解绑操作
  private handleUnbind(type: string): void {
    promptAction.showDialog({
      title: '解绑确认',
      message: `确定要解绑${this.getBindTypeName(type)}吗？`,
      buttons: [
        { text: '取消', color: ColorConstants.TEXT_SECONDARY },
        { text: '确定', color: ColorConstants.IOS_RED }
      ]
    }).then((result) => {
      if (result.index === 1) {
        // 执行解绑
        switch (type) {
          case 'wechat':
            this.bindStatus.wechat = false;
            this.wechatAccount = '';
            break;
          case 'qq':
            this.bindStatus.qq = false;
            this.qqAccount = '';
            break;
          case 'email':
            this.bindStatus.email = false;
            this.emailAccount = '';
            break;
          case 'phone':
            this.bindStatus.phone = false;
            this.phoneAccount = '';
            break;
        }
        this.saveBindStatus();
        CommonUtil.showToast('解绑成功');
      }
    });
  }
  
  // 确认绑定
  private confirmBind(): void {
    if (!this.inputAccount.trim()) {
      CommonUtil.showToast('请输入账号');
      return;
    }
    
    // 模拟绑定过程
    setTimeout(() => {
      switch (this.currentBindType) {
        case 'wechat':
          this.bindStatus.wechat = true;
          this.wechatAccount = this.inputAccount;
          break;
        case 'qq':
          this.bindStatus.qq = true;
          this.qqAccount = this.inputAccount;
          break;
        case 'email':
          if (!this.validateEmail(this.inputAccount)) {
            CommonUtil.showToast('邮箱格式不正确');
            return;
          }
          this.bindStatus.email = true;
          this.emailAccount = this.inputAccount;
          break;
        case 'phone':
          if (!this.validatePhone(this.inputAccount)) {
            CommonUtil.showToast('手机号格式不正确');
            return;
          }
          this.bindStatus.phone = true;
          this.phoneAccount = this.inputAccount;
          break;
      }
      
      this.saveBindStatus();
      this.showBindDialog = false;
      CommonUtil.showToast('绑定成功');
    }, 1000);
  }
  
  // 获取绑定类型名称
  private getBindTypeName(type: string): string {
    switch (type) {
      case 'wechat': return '微信';
      case 'qq': return 'QQ';
      case 'email': return '邮箱';
      case 'phone': return '手机号';
      default: return '';
    }
  }
  
  // 获取绑定类型图标
  private getBindTypeIcon(type: string): string {
    switch (type) {
      case 'wechat': return '💬';
      case 'qq': return '🐧';
      case 'email': return '📧';
      case 'phone': return '📱';
      default: return '🔗';
    }
  }
  
  // 获取绑定类型颜色
  private getBindTypeColor(type: string): string {
    switch (type) {
      case 'wechat': return '#07C160'; // 微信绿
      case 'qq': return '#12B7F5'; // QQ蓝
      case 'email': return ColorConstants.PRIMARY;
      case 'phone': return ColorConstants.TEAL;
      default: return ColorConstants.TEXT_TERTIARY;
    }
  }
  
  // 验证邮箱格式
  private validateEmail(email: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }
  
  // 验证手机号格式
  private validatePhone(phone: string): boolean {
    return /^1[3-9]\d{9}$/.test(phone);
  }
  
  // 绑定项组件
  @Builder
  BindItem(type: string, icon: string, name: string, color: string, isBound: boolean, account: string) {
    Row() {
      // 图标
      Column() {
        Text(icon)
          .fontSize(24)
      }
      .width(44)
      .height(44)
      .backgroundColor(this.isDarkMode ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.05)')
      .borderRadius(22)
      .justifyContent(FlexAlign.Center)
      
      // 名称和状态
      Column() {
        Text(name)
          .fontSize(16)
          .fontColor(this.getTextPrimary())
          .fontWeight(FontWeight.Medium)
        
        if (isBound) {
          Text(account)
            .fontSize(13)
            .fontColor(this.getTextSecondary())
            .margin({ top: 4 })
        } else {
          Text('未绑定')
            .fontSize(13)
            .fontColor(this.getTextTertiary())
            .margin({ top: 4 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })
      
      // 操作按钮
      if (isBound) {
        Button('解绑')
          .fontSize(14)
          .fontColor(ColorConstants.IOS_RED)
          .backgroundColor(ColorConstants.TRANSPARENT)
          .height(32)
          .onClick(() => {
            this.handleUnbind(type);
          })
      } else {
        Button('绑定')
          .fontSize(14)
          .fontColor(color)
          .backgroundColor(ColorConstants.TRANSPARENT)
          .height(32)
          .onClick(() => {
            this.handleBind(type);
          })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(this.getBgCard())
    .borderRadius(12)
  }
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        BackButton()
        
        Text('账号绑定')
          .fontSize(18)
          .fontColor(this.getTextPrimary())
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Blank()
          .width(40)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      
      Scroll() {
        Column() {
          // 学号信息卡片
          Column() {
            Row() {
              Text('🎓')
                .fontSize(20)
                .margin({ right: 12 })
              
              Text('当前学号')
                .fontSize(14)
                .fontColor(this.getTextSecondary())
              
              Blank()
              
              Text(this.studentId || '未登录')
                .fontSize(16)
                .fontColor(this.getTextPrimary())
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .padding(16)
          }
          .width('100%')
          .backgroundColor(this.getBgCard())
          .borderRadius(12)
          .margin({ top: 16, bottom: 24 })
          
          // 绑定说明
          Column() {
            Text('绑定第三方账号后，可以使用对应方式快速登录，同时可以接收相关通知消息。')
              .fontSize(13)
              .fontColor(this.getTextSecondary())
              .textAlign(TextAlign.Start)
          }
          .width('100%')
          .padding({ left: 4, right: 4, bottom: 16 })
          
          // 社交账号绑定
          Column() {
            Text('社交账号')
              .fontSize(15)
              .fontColor(this.getTextSecondary())
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .margin({ bottom: 12 })
            
            Column() {
              this.BindItem('wechat', this.getBindTypeIcon('wechat'), '微信', this.getBindTypeColor('wechat'), this.bindStatus.wechat, this.wechatAccount)
            }
            .width('100%')
            
            Column() {
              this.BindItem('qq', this.getBindTypeIcon('qq'), 'QQ', this.getBindTypeColor('qq'), this.bindStatus.qq, this.qqAccount)
            }
            .width('100%')
            .margin({ top: 12 })
          }
          .width('100%')
          .margin({ bottom: 24 })
          
          // 联系方式绑定
          Column() {
            Text('联系方式')
              .fontSize(15)
              .fontColor(this.getTextSecondary())
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .margin({ bottom: 12 })
            
            Column() {
              this.BindItem('email', this.getBindTypeIcon('email'), '邮箱', this.getBindTypeColor('email'), this.bindStatus.email, this.emailAccount)
            }
            .width('100%')
            
            Column() {
              this.BindItem('phone', this.getBindTypeIcon('phone'), '手机号', this.getBindTypeColor('phone'), this.bindStatus.phone, this.phoneAccount)
            }
            .width('100%')
            .margin({ top: 12 })
          }
          .width('100%')
          .margin({ bottom: 24 })
          
          // 安全提示
          Column() {
            Row() {
              Text('🔒')
                .fontSize(16)
                .margin({ right: 8 })
              
              Text('安全提示')
                .fontSize(14)
                .fontColor(this.getTextPrimary())
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .margin({ bottom: 8 })
            
            Text('请务必绑定您的真实联系方式，以便接收重要通知和找回密码。我们承诺保护您的隐私安全。')
              .fontSize(13)
              .fontColor(this.getTextSecondary())
              .lineHeight(20)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.isDarkMode ? 'rgba(255,255,255,0.05)' : 'rgba(0,0,0,0.03)')
          .borderRadius(12)
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 32 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.getBgColor())
    .bindSheet($$this.showBindDialog, this.BindDialogSheet(), {
      height: 320,
      backgroundColor: this.getBgCard(),
      dragBar: true
    })
  }
  
  // 绑定弹窗内容
  @Builder
  BindDialogSheet() {
    Column() {
      // 标题
      Text(`绑定${this.getBindTypeName(this.currentBindType)}`)
        .fontSize(18)
        .fontColor(this.getTextPrimary())
        .fontWeight(FontWeight.Medium)
        .margin({ top: 8, bottom: 24 })
      
      // 账号输入框
      Column() {
        TextInput({ 
          placeholder: this.currentBindType === 'email' ? '请输入邮箱地址' : 
                     this.currentBindType === 'phone' ? '请输入手机号' :
                     `请输入${this.getBindTypeName(this.currentBindType)}账号`,
          text: $$this.inputAccount
        })
          .fontSize(16)
          .placeholderColor(this.getTextTertiary())
          .backgroundColor(ColorConstants.TRANSPARENT)
          .width('100%')
          .height(48)
          .type(this.currentBindType === 'email' ? InputType.Email : 
                this.currentBindType === 'phone' ? InputType.PhoneNumber : InputType.Normal)
      }
      .width('100%')
      .backgroundColor(this.isDarkMode ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.05)')
      .borderRadius(12)
      .padding({ left: 16, right: 16 })
      .margin({ bottom: 16 })
      
      // 验证码输入框（如果是邮箱或手机号）
      if (this.currentBindType === 'email' || this.currentBindType === 'phone') {
        Row() {
          TextInput({ placeholder: '请输入验证码', text: $$this.inputCode })
            .fontSize(16)
            .placeholderColor(this.getTextTertiary())
            .backgroundColor(ColorConstants.TRANSPARENT)
            .layoutWeight(1)
            .height(48)
            .type(InputType.Number)
          
          Button('获取验证码')
            .fontSize(14)
            .fontColor(ColorConstants.PRIMARY)
            .backgroundColor(ColorConstants.TRANSPARENT)
            .height(48)
            .onClick(() => {
              CommonUtil.showToast('验证码已发送');
            })
        }
        .width('100%')
        .backgroundColor(this.isDarkMode ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.05)')
        .borderRadius(12)
        .padding({ left: 16, right: 8 })
        .margin({ bottom: 24 })
      }
      
      // 确认按钮
      Button('确认绑定')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor(ColorConstants.PRIMARY)
        .borderRadius(12)
        .onClick(() => {
          this.confirmBind();
        })
    }
    .width('100%')
    .padding({ left: 24, right: 24, bottom: 24 })
  }
}
