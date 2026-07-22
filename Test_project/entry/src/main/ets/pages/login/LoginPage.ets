import { ColorConstants } from '../../constant/ColorConstants';
import promptAction from '@ohos.promptAction';
import { AuthApi } from '../../network/api/AuthApi';
import { ApiConfig } from '../../network/ApiConfig';
import { ApiError } from '../../network/HttpClient';
import { Logger } from '../../utils/Logger';
import { PreferencesUtil } from '../../utils/PreferencesUtil';
import { PrefKeys } from '../../constant/AppConstants';

@Component
export struct LoginPage {
  @State studentId: string = '';
  @State password: string = '';
  @State isLoggingIn: boolean = false;
  @StorageLink('darkMode') isDarkMode: boolean = false;

  // 计算属性：根据深色模式返回对应颜色
  private getTextPrimary(): string {
    return this.isDarkMode ? ColorConstants.DARK_TEXT_PRIMARY : ColorConstants.TEXT_PRIMARY;
  }

  private getTextSecondary(): string {
    return this.isDarkMode ? ColorConstants.DARK_TEXT_SECONDARY : ColorConstants.TEXT_SECONDARY;
  }

  private getBgColor(): string {
    return this.isDarkMode ? ColorConstants.DARK_BG_PAGE : ColorConstants.BG_PAGE;
  }

  private getCardBgColor(): string {
    return this.isDarkMode ? ColorConstants.DARK_BG_CARD : ColorConstants.BG_CARD;
  }

  // 登录验证
  private async handleLogin(): Promise<void> {
    // 验证输入
    if (!this.studentId.trim()) {
      promptAction.showToast({
        message: '请输入学号',
        duration: 2000
      });
      return;
    }

    // 验证学号格式（通常为数字）
    if (!/^\d+$/.test(this.studentId.trim())) {
      promptAction.showToast({
        message: '学号格式不正确，请输入数字',
        duration: 2000
      });
      return;
    }

    if (!this.password.trim()) {
      promptAction.showToast({
        message: '请输入密码',
        duration: 2000
      });
      return;
    }

    // 设置登录中状态
    this.isLoggingIn = true;

    try {
      const resp = await AuthApi.login(this.studentId.trim(), this.password.trim());
      // 保存 token 与登录状态
      // 保存 token 与登录状态（持久化存储）
      ApiConfig.saveToken(resp.token);
      PreferencesUtil.putString(PrefKeys.STUDENT_ID, this.studentId);
      PreferencesUtil.putString(PrefKeys.USER_NAME, resp.userInfo?.name || '');
      
      // 同步到 AppStorage（内存存储，用于UI响应）
      AppStorage.setOrCreate('isLoggedIn', true);
      AppStorage.setOrCreate('studentId', this.studentId);
      AppStorage.setOrCreate('userName', resp.userInfo?.name || '');

      promptAction.showToast({
        message: '登录成功',
        duration: 1500
      });

      // 重置状态
      this.studentId = '';
      this.password = '';
    } catch (e) {
      const err = e as ApiError;
      const msg = err?.message || '登录失败，请重试';
      Logger.error('Login failed: code=' + err?.code + ' msg=' + msg);
      promptAction.showToast({
        message: msg,
        duration: 2000
      });
    } finally {
      this.isLoggingIn = false;
    }
  }

  build() {
    Column() {
      // 顶部装饰背景
      Column() {
        // 装饰圆形
        Column() {}
          .width(200)
          .height(200)
          .borderRadius(100)
          .linearGradient({
            angle: 135,
            colors: [
              [ColorConstants.PRIMARY, 0],
              [ColorConstants.TEAL, 1]
            ]
          })
          .opacity(0.15)
          .position({ x: -50, y: -50 })

        // Logo区域
        Column() {
          Text('🎓')
            .fontSize(60)
            .margin({ bottom: 16 })

          Text('校园助手')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getTextPrimary())

          Text('智慧校园生活服务平台')
            .fontSize(14)
            .fontColor(this.getTextSecondary())
            .margin({ top: 8 })
        }
        .width('100%')
        .padding({ top: 80, bottom: 40 })
      }
      .width('100%')
      .height(280)

      // 登录表单区域
      Column() {
        // 学号输入框
        Column() {
          Row() {
            Text('🎓')
              .fontSize(20)
              .margin({ right: 12 })

            TextInput({ placeholder: '请输入学号', text: this.studentId })
              .fontSize(16)
              .placeholderColor(ColorConstants.TEXT_TERTIARY)
              .backgroundColor(ColorConstants.TRANSPARENT)
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.studentId = value;
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        }
        .width('100%')
        .backgroundColor(this.getCardBgColor())
        .borderRadius(12)
        .margin({ bottom: 16 })

        // 密码输入框
        Column() {
          Row() {
            Text('🔒')
              .fontSize(20)
              .margin({ right: 12 })

            TextInput({ placeholder: '请输入密码', text: $$this.password })
              .fontSize(16)
              .placeholderColor(ColorConstants.TEXT_TERTIARY)
              .backgroundColor(ColorConstants.TRANSPARENT)
              .layoutWeight(1)
              .type(InputType.Password)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        }
        .width('100%')
        .backgroundColor(this.getCardBgColor())
        .borderRadius(12)
        .margin({ bottom: 24 })

        // 登录按钮
        Button() {
          if (this.isLoggingIn) {
            Row() {
              LoadingProgress()
                .width(20)
                .height(20)
                .color('#FFFFFF')
                .margin({ right: 8 })

              Text('登录中...')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .fontWeight(FontWeight.Medium)
            }
          } else {
            Text('登录')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Medium)
          }
        }
        .width('100%')
        .height(50)
        .backgroundColor(this.isLoggingIn ? ColorConstants.TEXT_TERTIARY : ColorConstants.PRIMARY)
        .borderRadius(12)
        .enabled(!this.isLoggingIn)
        .onClick(() => {
          this.handleLogin();
        })
        .gesture(
          LongPressGesture({ repeat: false })
            .onAction(() => {
              // 长按显示提示
              promptAction.showToast({
                message: '请输入学号和密码后点击登录',
                duration: 2000
              });
            })
        )
      }
      .width('100%')
      .padding({ left: 24, right: 24 })

      // 底部提示
      Column() {
        Text('登录即表示同意《用户协议》和《隐私政策》')
          .fontSize(12)
          .fontColor(this.getTextSecondary())
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.End)
      .padding({ bottom: 32 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.getBgColor())
  }
}
