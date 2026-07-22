import { ProfileViewModel } from '../../viewmodel/ProfileViewModel';
import { ColorConstants } from '../../constant/ColorConstants';
import { CommonUtil } from '../../utils/CommonUtil';
import { BackButton } from '../../components/common/BackButton';
import { PreferencesUtil } from '../../utils/PreferencesUtil';
import { PrefKeys } from '../../constant/AppConstants';
import router from '@ohos.router';

@Entry
@Component
export struct SettingsPage {
  @State viewModel: ProfileViewModel = new ProfileViewModel();
  @StorageLink('darkMode') isDarkMode: boolean = false;

  // 通知开关（响应式状态）
  @State isNotificationEnabled: boolean = true;
  // 字体大小（响应式状态）
  @State fontSize: number = 16;

  // 清除缓存确认对话框
  @State showClearCacheDialog: boolean = false;

  // 页面加载时初始化设置
  aboutToAppear(): void {
    this.isNotificationEnabled = this.viewModel.isNotificationEnabled;
    this.fontSize = this.viewModel.fontSize;
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

  private getBgPage(): string {
    return this.isDarkMode ? ColorConstants.DARK_BG_PAGE : ColorConstants.BG_PAGE;
  }

  private getBgCard(): string {
    return this.isDarkMode ? ColorConstants.DARK_BG_CARD : ColorConstants.BG_CARD;
  }

  private getDividerColor(): string {
    return this.isDarkMode ? ColorConstants.DARK_DIVIDER : ColorConstants.DIVIDER;
  }

  // 字体大小描述
  private getFontSizeLabel(): string {
    const size = this.fontSize;
    if (size <= 14) return '小';
    if (size <= 16) return '标准';
    if (size <= 18) return '大';
    return '特大';
  }

  // 分组标题（iOS风格：灰色小字号，左对齐）
  @Builder
  GroupHeader(title: string) {
    Text(title)
      .fontSize(13)
      .fontColor(this.getTextSecondary())
      .margin({ left: 16, bottom: 6, top: 18 })
  }

  // 带箭头的右侧内容
  @Builder
  ArrowRight() {
    Text('\u203A')
      .fontSize(20)
      .fontColor(this.getTextTertiary())
      .fontWeight(FontWeight.Bold)
  }

  // 清除缓存确认对话框（iOS风格Alert）
  @Builder
  ClearCacheAlertDialog() {
    Column() {
      Text('清除缓存')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getTextPrimary())
        .margin({ top: 16, bottom: 4 })

      Text('确定要清除 ' + this.viewModel.getCacheSizeText() + ' 缓存吗？')
        .fontSize(13)
        .fontColor(this.getTextSecondary())
        .margin({ bottom: 12 })

      Divider()
        .color(this.getDividerColor())

      Row() {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .fontSize(17)
          .fontColor(ColorConstants.IOS_BLUE)
          .backgroundColor(ColorConstants.TRANSPARENT)
          .fontWeight(FontWeight.Regular)
          .onClick(() => {
            this.showClearCacheDialog = false;
          })

        Divider()
          .vertical(true)
          .color(this.getDividerColor())
          .height(44)

        Button('清除')
          .layoutWeight(1)
          .height(44)
          .fontSize(17)
          .fontColor(ColorConstants.IOS_RED)
          .backgroundColor(ColorConstants.TRANSPARENT)
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.showClearCacheDialog = false;
            this.viewModel.clearCache(() => {
              CommonUtil.showToast('已清除');
            });
          })
      }
      .width('100%')
    }
    .width('80%')
    .backgroundColor(this.getBgCard())
    .borderRadius(14)
    .clip(true)
  }

  build() {
    Stack() {
      Column() {
        // 导航栏 - iOS大标题风格 + 返回按钮
        Column() {
          // 返回按钮行
          Row() {
            BackButton({ style: 'text', color: ColorConstants.IOS_BLUE })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 8, bottom: 4 })

          // 大标题
          Row() {
            Text('设置')
              .fontSize(34)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getTextPrimary())
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 8 })
        }
        .width('100%')
        .backgroundColor(this.getBgPage())

        Scroll() {
          Column() {
            // 通用设置分组
            this.GroupHeader('通用')

            Column() {
              Row() {
                // 左侧图标容器
                Row() {
                  Text('🌙')
                    .fontSize(16)
                }
                .width(28)
                .height(28)
                .borderRadius(7)
                .backgroundColor(ColorConstants.IOS_PURPLE)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)

                // 文字
                Text('深色模式')
                  .fontSize(16)
                  .fontColor(this.getTextPrimary())
                  .layoutWeight(1)
                  .margin({ left: 12 })

                // 右侧内容
                Toggle({ type: ToggleType.Switch, isOn: $$this.isDarkMode })
                  .selectedColor(ColorConstants.IOS_GREEN)
                  .switchPointColor(Color.White)
                  .animation({ duration: 300, curve: Curve.EaseInOut })
                  .onChange((isOn: boolean) => {
                    // 同步到 ViewModel 和 Preferences
                    this.viewModel.isDarkMode = isOn;
                    PreferencesUtil.putBoolean(PrefKeys.DARK_MODE, isOn);
                  })
              }
              .width('100%')
              .height(44)
              Divider()
                .color(this.getDividerColor())
                .margin({ left: 56 })
              Row() {
                // 左侧图标容器
                Row() {
                  Text('🔔')
                    .fontSize(16)
                }
                .width(28)
                .height(28)
                .borderRadius(7)
                .backgroundColor(ColorConstants.IOS_RED)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)

                // 文字
                Text('消息通知')
                  .fontSize(16)
                  .fontColor(this.getTextPrimary())
                  .layoutWeight(1)
                  .margin({ left: 12 })

                // 右侧内容
                Toggle({ type: ToggleType.Switch, isOn: $$this.isNotificationEnabled })
                  .selectedColor(ColorConstants.IOS_GREEN)
                  .switchPointColor(Color.White)
                  .animation({ duration: 300, curve: Curve.EaseInOut })
                  .onChange((isOn: boolean) => {
                    // 同步到 ViewModel 和 Preferences
                    this.viewModel.isNotificationEnabled = isOn;
                    PreferencesUtil.putBoolean(PrefKeys.NOTIFICATION_ENABLED, isOn);
                  })
              }
              .width('100%')
              .height(44)
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
            .backgroundColor(this.getBgCard())
            .borderRadius(12)
            .clip(true)

            // 显示设置分组
            this.GroupHeader('显示')

            Column() {
              Column() {
                Row() {
                  // 左侧图标容器
                  Row() {
                    Text('🔤')
                      .fontSize(16)
                  }
                  .width(28)
                  .height(28)
                  .borderRadius(7)
                  .backgroundColor(ColorConstants.IOS_BLUE)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(VerticalAlign.Center)

                  // 文字
                  Text('字体大小')
                    .fontSize(16)
                    .fontColor(this.getTextPrimary())
                    .layoutWeight(1)
                    .margin({ left: 12 })

                  // 字体大小描述
                  Text(this.getFontSizeLabel())
                    .fontSize(14)
                    .fontColor(this.getTextSecondary())
                }
                .width('100%')
                .height(44)

                // Slider 调节字体大小
                Row() {
                  Text('A')
                    .fontSize(12)
                    .fontColor(this.getTextTertiary())

                  Slider({
                    value: $$this.fontSize,
                    min: 12,
                    max: 22,
                    step: 1,
                    style: SliderStyle.OutSet
                  })
                    .blockColor(ColorConstants.IOS_BLUE)
                    .trackColor(this.isDarkMode ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.1)')
                    .selectedColor(ColorConstants.IOS_BLUE)
                    .layoutWeight(1)
                    .margin({ left: 12, right: 12 })
                    .onChange((value: number) => {
                      // 同步到 ViewModel 和 Preferences
                      const newSize = Math.round(value);
                      this.viewModel.fontSize = newSize;
                      PreferencesUtil.putNumber(PrefKeys.FONT_SIZE, newSize);
                    })

                  Text('A')
                    .fontSize(20)
                    .fontColor(this.getTextTertiary())
                }
                .width('100%')
                .padding({ bottom: 12, top: 4 })
              }
              .width('100%')
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
            .backgroundColor(this.getBgCard())
            .borderRadius(12)
            .clip(true)
            .margin({ bottom: 4 })

            // 数据管理分组
            this.GroupHeader('数据管理')

            Column() {
              Row() {
                // 左侧图标容器
                Row() {
                  Text('🗑️')
                    .fontSize(16)
                }
                .width(28)
                .height(28)
                .borderRadius(7)
                .backgroundColor('#8E8E93')
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)

                // 文字
                Text('清除缓存')
                  .fontSize(16)
                  .fontColor(this.getTextPrimary())
                  .layoutWeight(1)
                  .margin({ left: 12 })

                // 右侧内容
                Row() {
                  Text(this.viewModel.getCacheSizeText())
                    .fontSize(14)
                    .fontColor(this.getTextSecondary())
                    .animation({ duration: 200, curve: Curve.EaseInOut })
                  Text('›')
                    .fontSize(20)
                    .fontColor(this.getTextTertiary())
                    .fontWeight(FontWeight.Bold)
                    .margin({ left: 4 })
                }
              }
              .width('100%')
              .height(44)
              .onClick(() => {
                if (!this.viewModel.isClearingCache) {
                  this.showClearCacheDialog = true;
                }
              })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
            .backgroundColor(this.getBgCard())
            .borderRadius(12)
            .clip(true)
            .margin({ bottom: 4 })

            // 关于分组
            this.GroupHeader('关于')

            Column() {
              Row() {
                // 左侧图标容器
                Row() {
                  Text('📱')
                    .fontSize(16)
                }
                .width(28)
                .height(28)
                .borderRadius(7)
                .backgroundColor(ColorConstants.IOS_BLUE)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)

                // 文字
                Text('版本号')
                  .fontSize(16)
                  .fontColor(this.getTextPrimary())
                  .layoutWeight(1)
                  .margin({ left: 12 })

                // 右侧内容
                Text(this.viewModel.getAppVersion())
                  .fontSize(14)
                  .fontColor(this.getTextSecondary())
              }
              .width('100%')
              .height(44)
              Divider()
                .color(this.getDividerColor())
                .margin({ left: 56 })
              Row() {
                // 左侧图标容器
                Row() {
                  Text('🔄')
                    .fontSize(16)
                }
                .width(28)
                .height(28)
                .borderRadius(7)
                .backgroundColor(ColorConstants.IOS_GREEN)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)

                // 文字
                Text('检查更新')
                  .fontSize(16)
                  .fontColor(this.getTextPrimary())
                  .layoutWeight(1)
                  .margin({ left: 12 })

                // 右侧内容
                Row() {
                  Text('已是最新')
                    .fontSize(14)
                    .fontColor(this.getTextSecondary())
                  Text('›')
                    .fontSize(20)
                    .fontColor(this.getTextTertiary())
                    .fontWeight(FontWeight.Bold)
                    .margin({ left: 4 })
                }
              }
              .width('100%')
              .height(44)
              .onClick(() => {
                CommonUtil.showToast('已是最新版本');
              })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
            .backgroundColor(this.getBgCard())
            .borderRadius(12)
            .clip(true)
            .margin({ bottom: 4 })

            // 协议与政策分组
            this.GroupHeader('协议与政策')

            Column() {
              Row() {
                // 左侧图标容器
                Row() {
                  Text('📄')
                    .fontSize(16)
                }
                .width(28)
                .height(28)
                .borderRadius(7)
                .backgroundColor(ColorConstants.IOS_BLUE)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)

                // 文字
                Text('用户协议')
                  .fontSize(16)
                  .fontColor(this.getTextPrimary())
                  .layoutWeight(1)
                  .margin({ left: 12 })

                // 右侧内容
                Text('›')
                  .fontSize(20)
                  .fontColor(this.getTextTertiary())
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')
              .height(44)
              .onClick(() => {
                CommonUtil.showToast('用户协议');
              })
              Divider()
                .color(this.getDividerColor())
                .margin({ left: 56 })
              Row() {
                // 左侧图标容器
                Row() {
                  Text('🔒')
                    .fontSize(16)
                }
                .width(28)
                .height(28)
                .borderRadius(7)
                .backgroundColor(ColorConstants.IOS_BLUE)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)

                // 文字
                Text('隐私政策')
                  .fontSize(16)
                  .fontColor(this.getTextPrimary())
                  .layoutWeight(1)
                  .margin({ left: 12 })

                // 右侧内容
                Text('›')
                  .fontSize(20)
                  .fontColor(this.getTextTertiary())
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')
              .height(44)
              .onClick(() => {
                CommonUtil.showToast('隐私政策');
              })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
            .backgroundColor(this.getBgCard())
            .borderRadius(12)
            .clip(true)
            .margin({ bottom: 4 })

            // 反馈分组
            this.GroupHeader('反馈')

            Column() {
              Row() {
                // 左侧图标容器
                Row() {
                  Text('💬')
                    .fontSize(16)
                }
                .width(28)
                .height(28)
                .borderRadius(7)
                .backgroundColor(ColorConstants.IOS_ORANGE)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center)

                // 文字
                Text('意见反馈')
                  .fontSize(16)
                  .fontColor(this.getTextPrimary())
                  .layoutWeight(1)
                  .margin({ left: 12 })

                // 右侧内容
                Text('›')
                  .fontSize(20)
                  .fontColor(this.getTextTertiary())
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')
              .height(44)
              .onClick(() => {
                CommonUtil.showToast('意见反馈');
              })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
            .backgroundColor(this.getBgCard())
            .borderRadius(12)
            .clip(true)
            .margin({ bottom: 20 })
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.getBgPage())
      .animation({ duration: 300, curve: Curve.EaseInOut })

      // 清除缓存确认对话框遮罩
      if (this.showClearCacheDialog) {
        Column() {
          this.ClearCacheAlertDialog()
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.4)')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.showClearCacheDialog = false;
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
