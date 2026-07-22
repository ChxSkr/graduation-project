import { ColorConstants } from '../constant/ColorConstants';
import { HomePage } from './home/HomePage';
import { SchedulePage } from './schedule/SchedulePage';
import { NewsPage } from './news/NewsPage';
import { ProfilePage } from './profile/ProfilePage';
import { ActivityPage } from './activity/ActivityPage';
import { LoginPage } from './login/LoginPage';
import { SegmentedTabBar, SegTabItem } from '../components/common/SegmentedTabBar';
import { ApiConfig } from '../network/ApiConfig';
import { PreferencesUtil } from '../utils/PreferencesUtil';
import { PrefKeys } from '../constant/AppConstants';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  @Provide('currentPageIndex') currentPageIndex: number = 0;
  @StorageLink('isLoggedIn') isLoggedIn: boolean = false;

  // 分段控件配置（5个段：首页/资讯/课表/活动/我的）
  private tabs: SegTabItem[] = [
    { title: '首页', icon: '🏠' },
    { title: '资讯', icon: '📰' },
    { title: '课表', icon: '📅' },
    { title: '活动', icon: '🎉' },
    { title: '我的', icon: '👤' }
  ];

  // 页面加载时恢复登录状态
  aboutToAppear(): void {
    // 从 Preferences 恢复登录状态到 AppStorage
    if (ApiConfig.isLoggedIn()) {
      AppStorage.setOrCreate('isLoggedIn', true);
      const studentId = PreferencesUtil.getString(PrefKeys.STUDENT_ID, '');
      const userName = PreferencesUtil.getString(PrefKeys.USER_NAME, '');
      if (studentId) {
        AppStorage.setOrCreate('studentId', studentId);
      }
      if (userName) {
        AppStorage.setOrCreate('userName', userName);
      }
    }
  }

  build() {
    Column() {
      // 检查登录状态
      if (!this.isLoggedIn) {
        // 未登录时显示登录页面
        LoginPage()
      } else {
        // 已登录时显示主界面
        Column() {
          // 页面内容区域（条件渲染，不响应左右滑动）
          Column() {
            if (this.currentIndex === 0) {
              this.HomeNavContainer()
            } else if (this.currentIndex === 1) {
              this.NewsNavContainer()
            } else if (this.currentIndex === 2) {
              this.ScheduleNavContainer()
            } else if (this.currentIndex === 3) {
              this.ActivityNavContainer()
            } else if (this.currentIndex === 4) {
              this.ProfileNavContainer()
            }
          }
          .width('100%')
          .layoutWeight(1)

          // 分段控件底部导航栏（左右滑动滑块或点击标签切换内容）
          SegmentedTabBar({
            tabs: this.tabs,
            currentIndex: $currentIndex,
            onTabChange: (index: number) => {
              this.currentPageIndex = index;
            }
          })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(ColorConstants.BG_PAGE)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  HomeNavContainer() {
    Navigation() {
      HomePage()
    }
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
  }

  @Builder
  NewsNavContainer() {
    Navigation() {
      NewsPage()
    }
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
  }

  @Builder
  ScheduleNavContainer() {
    Navigation() {
      SchedulePage()
    }
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
  }

  @Builder
  ActivityNavContainer() {
    Navigation() {
      ActivityPage()
    }
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
  }

  @Builder
  ProfileNavContainer() {
    Navigation() {
      ProfilePage()
    }
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
  }
}
