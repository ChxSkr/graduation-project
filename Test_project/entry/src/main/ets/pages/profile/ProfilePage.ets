import { ProfileViewModel } from '../../viewmodel/ProfileViewModel';
import { ColorConstants } from '../../constant/ColorConstants';
import { CommonUtil } from '../../utils/CommonUtil';
import router from '@ohos.router';
import { UserInfo } from '../../model/User';
import { UserApi } from '../../network/api/UserApi';
import { ApiConfig } from '../../network/ApiConfig';
import { Logger } from '../../utils/Logger';

// 菜单项接口
interface MenuItemData {
  icon: string;
  color: string;
  label: string;
}

@Entry
@Component
export struct ProfilePage {
  @State viewModel: ProfileViewModel = new ProfileViewModel();
  @StorageLink('darkMode') isDarkMode: boolean = false;

  // 下拉刷新状态
  @State isRefreshing: boolean = false;

  // 菜单项按下状态（用于动画）
  @State menuItemsVisible: boolean = false;
  @State showLogoutDialog: boolean = false;

  // 用户信息（响应式状态）
  @State userInfo: UserInfo | null = null;
  @State isLoading: boolean = false;

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

  // 菜单项按下状态
  @State pressedIndex: number = -1;

  // 功能菜单数据
  private readonly functionMenus: MenuItemData[] = [
    { icon: '📚', color: ColorConstants.IOS_ORANGE, label: '我的课程' } as MenuItemData,
    { icon: '💳', color: ColorConstants.IOS_GREEN, label: '校园卡' } as MenuItemData,
    { icon: '⭐', color: ColorConstants.IOS_YELLOW, label: '我的收藏' } as MenuItemData,
    { icon: '📝', color: ColorConstants.IOS_BLUE, label: '我的发布' } as MenuItemData,
    { icon: '🕐', color: ColorConstants.IOS_PURPLE, label: '浏览历史' } as MenuItemData
  ];

  private readonly serviceMenus: MenuItemData[] = [
    { icon: '🔔', color: ColorConstants.IOS_RED, label: '消息通知' } as MenuItemData,
    { icon: '💬', color: ColorConstants.IOS_TEAL, label: '帮助与反馈' } as MenuItemData
  ];

  aboutToAppear(): void {
    // 页面出现后触发列表项动画
    setTimeout(() => {
      this.menuItemsVisible = true;
    }, 100);
    // 加载用户信息
    this.loadUserInfo();
  }

  // 从子页面返回时刷新用户信息
  onPageShow(): void {
    this.loadUserInfo();
  }

  // 加载用户信息
  async loadUserInfo(): Promise<void> {
    if (!ApiConfig.isLoggedIn()) {
      Logger.info('ProfilePage: not logged in, skip loading user info');
      return;
    }
    this.isLoading = true;
    try {
      this.userInfo = await UserApi.getInfo();
      Logger.info('ProfilePage: user info loaded - ' + this.userInfo?.name);
    } catch (e) {
      Logger.error('ProfilePage: failed to load user info - ' + JSON.stringify(e));
    } finally {
      this.isLoading = false;
    }
  }

  // 下拉刷新处理
  onRefresh(): void {
    this.isRefreshing = true;
    this.viewModel.refreshData(() => {
      this.isRefreshing = false;
      CommonUtil.showToast('刷新成功');
    });
  }

  // iOS风格菜单项：左图标（带颜色圆角方形背景）+ 文字 + 右箭头
  @Builder
  MenuItem(icon: string, iconBgColor: string, label: string, index: number, onClick: () => void) {
    Row() {
      // 左侧图标容器：圆角方形 + 彩色背景
      Row() {
        Text(icon)
          .fontSize(18)
      }
      .width(30)
      .height(30)
      .borderRadius(8)
      .backgroundColor(iconBgColor)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      // 文字
      Text(label)
        .fontSize(16)
        .fontColor(this.getTextPrimary())
        .layoutWeight(1)
        .margin({ left: 12 })

      // 右箭头指示器（iOS风格 chevron）
      Text('\u203A')
        .fontSize(20)
        .fontColor(this.getTextTertiary())
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .height(44)
    .backgroundColor(this.pressedIndex === index ?
      (this.isDarkMode ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.05)') :
      this.getBgCard())
    .animation({ duration: 150, curve: Curve.EaseInOut })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.pressedIndex = index;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.pressedIndex = -1;
      }
    })
    .onClick(() => onClick())
  }

  // 分组标题（iOS风格：灰色小字号，左对齐）
  @Builder
  GroupHeader(title: string) {
    Text(title)
      .fontSize(13)
      .fontColor(this.getTextSecondary())
      .margin({ left: 16, bottom: 6, top: 18 })
  }

  // 统计数据项
  @Builder
  StatItem(value: number, label: string) {
    Column() {
      Text(value.toString())
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getTextPrimary())
      Text(label)
        .fontSize(12)
        .fontColor(this.getTextSecondary())
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  // 退出登录确认对话框（iOS风格Alert）
  @Builder
  LogoutAlertDialog() {
    Column() {
      Text('退出登录')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getTextPrimary())
        .margin({ top: 16, bottom: 4 })

      Text('确定要退出登录吗？')
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
            this.showLogoutDialog = false;
          })

        Divider()
          .vertical(true)
          .color(this.getDividerColor())
          .height(44)

        Button('退出登录')
          .layoutWeight(1)
          .height(44)
          .fontSize(17)
          .fontColor(ColorConstants.IOS_RED)
          .backgroundColor(ColorConstants.TRANSPARENT)
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.showLogoutDialog = false;
            // 清除本地 token 与登录状态
            this.viewModel.logout();
            CommonUtil.showToast('已退出登录');
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
        // 导航栏 - iOS大标题风格
        Row() {
          Text('我的')
            .fontSize(34)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getTextPrimary())
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 8, bottom: 8 })
        .backgroundColor(this.getBgPage())

        // 可滚动内容
        Scroll() {
          Column() {
            // 用户信息卡片 - iOS分组风格
            Column() {
              Row() {
                // 头像 - 蓝青渐变圆形 + 姓名首字（与首页问候区风格统一）
                Stack() {
                  Circle()
                    .width(60)
                    .height(60)
                    .linearGradient({
                      direction: GradientDirection.LeftBottom,
                      colors: [
                        [ColorConstants.PRIMARY, 0.0],
                        [ColorConstants.TEAL, 1.0]
                      ]
                    })

                  Text(this.userInfo?.name?.charAt(0) || '👤')
                    .fontSize(26)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#FFFFFF')
                }
                .width(60)
                .height(60)
                .borderRadius(30)
                .border({ width: 3, color: this.isDarkMode ? ColorConstants.DARK_BG_CARD : '#FFFFFF' })
                .shadow({
                  radius: 10,
                  color: 'rgba(10, 89, 247, 0.25)',
                  offsetX: 0,
                  offsetY: 4
                })

                // 信息
                Column() {
                  Text(this.userInfo?.name || '未登录')
                    .fontSize(17)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.getTextPrimary())

                  Text('学号：' + (this.userInfo?.studentId || '--'))
                    .fontSize(14)
                    .fontColor(this.getTextSecondary())
                    .margin({ top: 2 })

                  Text(this.userInfo?.college || '')
                    .fontSize(13)
                    .fontColor(this.getTextTertiary())
                    .margin({ top: 2 })
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({ left: 14 })

                // iOS风格右箭头（编辑指示器）
                Text('\u203A')
                  .fontSize(20)
                  .fontColor(this.getTextTertiary())
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')
              .height(76)
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
            .backgroundColor(this.getBgCard())
            .borderRadius(12)
            .margin({ top: 8, bottom: 4 })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/profile/EditProfilePage'
              });
            })
            .transition({ type: TransitionType.All, opacity: 0, translate: { y: 20 } })
            .animation({ duration: 400, curve: Curve.EaseOut })
            .scale({ x: this.menuItemsVisible ? 1 : 0.95, y: this.menuItemsVisible ? 1 : 0.95 })
            .opacity(this.menuItemsVisible ? 1 : 0)
            .animation({ duration: 500, curve: Curve.EaseOut })

            // 数据统计卡片 - 三列展示
            Row() {
              this.StatItem(this.viewModel.publishedCount, '已发布')
              Divider()
                .vertical(true)
                .color(this.getDividerColor())
                .height(28)
              this.StatItem(this.viewModel.favoritesCount, '收藏数')
              Divider()
                .vertical(true)
                .color(this.getDividerColor())
                .height(28)
              this.StatItem(this.viewModel.messagesCount, '消息数')
            }
            .width('100%')
            .padding({ top: 14, bottom: 14 })
            .backgroundColor(this.getBgCard())
            .borderRadius(12)
            .margin({ bottom: 4 })
            .opacity(this.menuItemsVisible ? 1 : 0)
            .translate({ y: this.menuItemsVisible ? 0 : 20 })
            .animation({ duration: 500, curve: Curve.EaseOut, delay: 80 })

            // 功能分组标题
            this.GroupHeader('功能')

            // 功能菜单 - iOS分组卡片
            Column() {
              ForEach(this.functionMenus, (item: MenuItemData, index: number) => {
                if (index > 0) {
                  Divider()
                    .color(this.getDividerColor())
                    .margin({ left: 58 })
                }
                this.MenuItem(item.icon, item.color, item.label, index, () => {
                  // 根据菜单项跳转到对应页面
                  if (item.label === '我的课程') {
                    router.pushUrl({ url: 'pages/schedule/SchedulePage' });
                  } else if (item.label === '校园卡') {
                    router.pushUrl({ url: 'pages/card/CardPage' });
                  } else if (item.label === '我的发布') {
                    router.pushUrl({ url: 'pages/lostfound/MyPublishPage' });
                  } else {
                    CommonUtil.showToast(item.label);
                  }
                })
              }, (item: MenuItemData) => item.label)
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
            .backgroundColor(this.getBgCard())
            .borderRadius(12)
            .clip(true)
            .margin({ bottom: 4 })
            .opacity(this.menuItemsVisible ? 1 : 0)
            .translate({ y: this.menuItemsVisible ? 0 : 30 })
            .animation({ duration: 500, curve: Curve.EaseOut, delay: 120 })

            // 服务分组标题
            this.GroupHeader('服务')

            Column() {
              ForEach(this.serviceMenus, (item: MenuItemData, index: number) => {
                if (index > 0) {
                  Divider()
                    .color(this.getDividerColor())
                    .margin({ left: 58 })
                }
                this.MenuItem(item.icon, item.color, item.label, index + this.functionMenus.length, () => {
                  if (item.label === '消息通知') {
                    router.pushUrl({ url: 'pages/profile/SettingsPage' });
                  } else {
                    CommonUtil.showToast(item.label);
                  }
                })
              }, (item: MenuItemData) => item.label)
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
            .backgroundColor(this.getBgCard())
            .borderRadius(12)
            .clip(true)
            .margin({ bottom: 4 })
            .opacity(this.menuItemsVisible ? 1 : 0)
            .translate({ y: this.menuItemsVisible ? 0 : 30 })
            .animation({ duration: 500, curve: Curve.EaseOut, delay: 160 })

            // 设置分组
            this.GroupHeader('设置')

            Column() {
              this.MenuItem('⚙️', '#8E8E93', '设置', this.functionMenus.length + this.serviceMenus.length, () => {
                router.pushUrl({ url: 'pages/profile/SettingsPage' });
              })
              Divider()
                .color(this.getDividerColor())
                .margin({ left: 58 })
              this.MenuItem('🔗', ColorConstants.PRIMARY, '账号绑定', this.functionMenus.length + this.serviceMenus.length + 1, () => {
                router.pushUrl({ url: 'pages/profile/AccountBindPage' });
              })
              Divider()
                .color(this.getDividerColor())
                .margin({ left: 58 })
              this.MenuItem('ℹ️', ColorConstants.IOS_BLUE, '关于我们', this.functionMenus.length + this.serviceMenus.length + 2, () => {
                CommonUtil.showToast('关于我们');
              })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
            .backgroundColor(this.getBgCard())
            .borderRadius(12)
            .clip(true)
            .margin({ bottom: 32 })
            .opacity(this.menuItemsVisible ? 1 : 0)
            .translate({ y: this.menuItemsVisible ? 0 : 30 })
            .animation({ duration: 500, curve: Curve.EaseOut, delay: 200 })

            // 退出登录 - iOS风格红色文字居中白色卡片
            Button('退出登录')
              .width('100%')
              .height(44)
              .fontSize(16)
              .fontColor(ColorConstants.IOS_RED)
              .backgroundColor(this.getBgCard())
              .borderRadius(12)
              .fontWeight(FontWeight.Medium)
              .onClick(() => {
                this.showLogoutDialog = true;
              })
              .opacity(this.menuItemsVisible ? 1 : 0)
              .translate({ y: this.menuItemsVisible ? 0 : 30 })
              .animation({ duration: 500, curve: Curve.EaseOut, delay: 240 })

            // 版本信息 - iOS风格底部小字
            Text('版本 ' + this.viewModel.getAppVersion())
              .fontSize(12)
              .fontColor(this.getTextTertiary())
              .margin({ top: 16, bottom: 20 })
              .opacity(this.menuItemsVisible ? 1 : 0)
              .animation({ duration: 500, curve: Curve.EaseOut, delay: 280 })
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .onScrollFrameBegin((offset: number) => {
          // 下拉刷新检测
          return { offsetRemain: offset };
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.getBgPage())

      // 下拉刷新指示器（自定义）
      if (this.isRefreshing) {
        Column() {
          LoadingProgress()
            .width(30)
            .height(30)
            .color(this.getTextSecondary())
        }
        .width('100%')
        .padding({ top: 60 })
        .justifyContent(FlexAlign.Start)
      }

      // 退出登录确认对话框遮罩
      if (this.showLogoutDialog) {
        Column() {
          this.LogoutAlertDialog()
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.4)')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.showLogoutDialog = false;
        })
      }
    }
    .width('100%')
    .height('100%')
    .onClick(() => {
      // 用于下拉刷新手势
    })
    .gesture(
      PanGesture({ direction: PanDirection.Down, distance: 60 })
        .onActionStart(() => {
          if (!this.isRefreshing) {
            this.isRefreshing = true;
            this.onRefresh();
          }
        })
    )
  }
}
