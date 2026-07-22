import { ColorConstants } from '../../constant/ColorConstants';
import { CommonUtil } from '../../utils/CommonUtil';
import { BackButton } from '../../components/common/BackButton';
import { UserInfo } from '../../model/User';
import { UserApi } from '../../network/api/UserApi';
import { ApiConfig } from '../../network/ApiConfig';
import { Logger } from '../../utils/Logger';
import { PreferencesUtil } from '../../utils/PreferencesUtil';
import { PrefKeys } from '../../constant/AppConstants';
import router from '@ohos.router';

/**
 * 个人资料编辑页面
 * iOS 风格分组列表，支持编辑姓名、学院、专业、年级、联系方式等
 */
@Entry
@Component
struct EditProfilePage {
  @StorageLink('darkMode') isDarkMode: boolean = false;

  // 表单字段
  @State name: string = '';
  @State studentId: string = '';
  @State college: string = '';
  @State major: string = '';
  @State grade: string = '';
  @State phone: string = '';
  @State email: string = '';

  // 状态
  @State isSaving: boolean = false;
  @State hasChanges: boolean = false;
  @State originalData: string = '';

  aboutToAppear(): void {
    if (!ApiConfig.isLoggedIn()) {
      CommonUtil.showToast('请先登录');
      router.back();
      return;
    }
    this.loadUserInfo();
  }

  // 从后端加载用户信息
  private async loadUserInfo(): Promise<void> {
    try {
      const info = await UserApi.getInfo();
      this.name = info.name || '';
      this.studentId = info.studentId || '';
      this.college = info.college || '';
      this.major = info.major || '';
      this.grade = info.grade || '';
      this.phone = info.phone || '';
      this.email = info.email || '';
      // 记录原始数据用于变更检测
      this.originalData = this.buildSnapshot();
    } catch (e) {
      Logger.error('EditProfilePage: load failed - ' + JSON.stringify(e));
      CommonUtil.showToast('加载失败');
    }
  }

  // 构建当前数据快照
  private buildSnapshot(): string {
    return `${this.name}|${this.college}|${this.major}|${this.grade}|${this.phone}|${this.email}`;
  }

  // 检查是否有修改
  private checkChanges(): void {
    this.hasChanges = this.buildSnapshot() !== this.originalData;
  }

  // 保存用户信息
  private async saveUserInfo(): Promise<void> {
    if (!this.name.trim()) {
      CommonUtil.showToast('请输入姓名');
      return;
    }
    if (this.phone && !this.validatePhone(this.phone)) {
      CommonUtil.showToast('手机号格式不正确');
      return;
    }
    if (this.email && !this.validateEmail(this.email)) {
      CommonUtil.showToast('邮箱格式不正确');
      return;
    }

    this.isSaving = true;
    try {
      const info = await UserApi.updateInfo({
        name: this.name.trim(),
        college: this.college.trim(),
        major: this.major.trim(),
        grade: this.grade.trim(),
        phone: this.phone.trim(),
        email: this.email.trim()
      });
      // 更新 AppStorage 和 Preferences 中的用户名（首页问候区同步）
      if (info?.name) {
        AppStorage.setOrCreate('userName', info.name);
        PreferencesUtil.putString(PrefKeys.USER_NAME, info.name);
      }
      this.originalData = this.buildSnapshot();
      this.hasChanges = false;
      CommonUtil.showToast('保存成功');
      // 延迟返回，让用户看到提示
      setTimeout(() => {
        router.back();
      }, 500);
    } catch (e) {
      Logger.error('EditProfilePage: save failed - ' + JSON.stringify(e));
      CommonUtil.showToast('保存失败，请重试');
    } finally {
      this.isSaving = false;
    }
  }

  // 手机号校验
  private validatePhone(phone: string): boolean {
    return /^1[3-9]\d{9}$/.test(phone);
  }

  // 邮箱校验
  private validateEmail(email: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }

  // 深色模式颜色辅助方法
  private getTextPrimary(): string {
    return this.isDarkMode ? ColorConstants.DARK_TEXT_PRIMARY : ColorConstants.TEXT_PRIMARY;
  }

  private getTextSecondary(): string {
    return this.isDarkMode ? ColorConstants.DARK_TEXT_SECONDARY : ColorConstants.TEXT_SECONDARY;
  }

  private getTextTertiary(): string {
    return this.isDarkMode ? ColorConstants.DARK_TEXT_TERTIARY : ColorConstants.TEXT_TERTIARY;
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

  // 头像首字
  private getAvatarChar(): string {
    return this.name?.charAt(0) || '👤';
  }

  // iOS 风格表单行：左标签 + 右输入框
  @Builder
  FormRow(label: string, placeholder: string, value: string, onChange: (val: string) => void, editable: boolean = true) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor(this.getTextPrimary())
        .width(80)

      TextInput({ placeholder: placeholder, text: value })
        .fontSize(16)
        .fontColor(editable ? this.getTextPrimary() : this.getTextTertiary())
        .placeholderColor(this.getTextTertiary())
        .layoutWeight(1)
        .height(44)
        .backgroundColor(ColorConstants.TRANSPARENT)
        .textAlign(TextAlign.End)
        .enabled(editable)
        .onChange((val: string) => {
          onChange(val);
          this.checkChanges();
        })
    }
    .width('100%')
    .height(48)
    .padding({ left: 16, right: 16 })
  }

  // 分组标题
  @Builder
  GroupHeader(title: string) {
    Text(title)
      .fontSize(13)
      .fontColor(this.getTextSecondary())
      .margin({ left: 16, bottom: 6, top: 18 })
  }

  build() {
    Column() {
      // 顶部导航栏（与 AccountBindPage 一致）
      Row() {
        BackButton()

        Text('编辑资料')
          .fontSize(18)
          .fontColor(this.getTextPrimary())
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 保存按钮
        Text('保存')
          .fontSize(16)
          .fontColor(this.hasChanges && !this.isSaving ? ColorConstants.IOS_BLUE : this.getTextTertiary())
          .fontWeight(this.hasChanges ? FontWeight.Medium : FontWeight.Regular)
          .width(40)
          .textAlign(TextAlign.End)
          .onClick(() => {
            if (this.hasChanges && !this.isSaving) {
              this.saveUserInfo();
            }
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(this.getBgPage())

      // 可滚动内容
      Scroll() {
        Column() {
          // 头像区域
          Column() {
            Stack() {
              Circle()
                .width(80)
                .height(80)
                .linearGradient({
                  direction: GradientDirection.LeftBottom,
                  colors: [
                    [ColorConstants.PRIMARY, 0.0],
                    [ColorConstants.TEAL, 1.0]
                  ]
                })

              Text(this.getAvatarChar())
                .fontSize(34)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .width(80)
            .height(80)
            .borderRadius(40)
            .border({ width: 3, color: this.isDarkMode ? ColorConstants.DARK_BG_CARD : '#FFFFFF' })
            .shadow({
              radius: 12,
              color: 'rgba(10, 89, 247, 0.25)',
              offsetX: 0,
              offsetY: 4
            })

            Text('点击修改头像')
              .fontSize(13)
              .fontColor(this.getTextTertiary())
              .margin({ top: 8 })
          }
          .width('100%')
          .padding({ top: 24, bottom: 8 })
          .alignItems(HorizontalAlign.Center)

          // 基本信息
          this.GroupHeader('基本信息')

          Column() {
            this.FormRow('姓名', '请输入姓名', this.name, (val: string) => { this.name = val; })
            Divider().color(this.getDividerColor()).margin({ left: 16 })
            this.FormRow('学号', '学号', this.studentId, (val: string) => { this.studentId = val; }, false)
          }
          .width('100%')
          .backgroundColor(this.getBgCard())
          .borderRadius(12)
          .clip(true)

          // 院系信息
          this.GroupHeader('院系信息')

          Column() {
            this.FormRow('学院', '请输入学院', this.college, (val: string) => { this.college = val; })
            Divider().color(this.getDividerColor()).margin({ left: 16 })
            this.FormRow('专业', '请输入专业', this.major, (val: string) => { this.major = val; })
            Divider().color(this.getDividerColor()).margin({ left: 16 })
            this.FormRow('年级', '请输入年级', this.grade, (val: string) => { this.grade = val; })
          }
          .width('100%')
          .backgroundColor(this.getBgCard())
          .borderRadius(12)
          .clip(true)

          // 联系方式
          this.GroupHeader('联系方式')

          Column() {
            this.FormRow('手机号', '请输入手机号', this.phone, (val: string) => { this.phone = val; })
            Divider().color(this.getDividerColor()).margin({ left: 16 })
            this.FormRow('邮箱', '请输入邮箱', this.email, (val: string) => { this.email = val; })
          }
          .width('100%')
          .backgroundColor(this.getBgCard())
          .borderRadius(12)
          .clip(true)

          // 底部保存按钮
          Button(this.isSaving ? '保存中...' : '保存修改')
            .width('100%')
            .height(50)
            .fontSize(17)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
            .backgroundColor(this.hasChanges && !this.isSaving ? ColorConstants.IOS_BLUE : this.getTextTertiary())
            .borderRadius(12)
            .margin({ top: 32, bottom: 32 })
            .enabled(this.hasChanges && !this.isSaving)
            .onClick(() => {
              this.saveUserInfo();
            })
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.getBgPage())
  }
}
