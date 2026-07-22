import router from '@ohos.router';
import { ColorConstants } from '../../constant/ColorConstants';
import { BackButton } from '../../components/common/BackButton';
import { CommonUtil } from '../../utils/CommonUtil';

/**
 * 更多服务页面
 * 展示所有可用服务的列表
 */
@Entry
@Component
struct MoreServicesPage {
  // 服务列表数据
  private services: ServiceItem[] = [
    { id: 's1', name: '图书馆', icon: '📚', desc: '图书借阅、座位预约' },
    { id: 's2', name: '课程表', icon: '📅', desc: '查看本周课程安排' },
    { id: 's3', name: '成绩查询', icon: '📊', desc: '查看学期成绩' },
    { id: 's4', name: '校园卡', icon: '💳', desc: '余额查询、充值服务' },
    { id: 's5', name: '校园活动', icon: '🎉', desc: '活动报名、签到' },
    { id: 's6', name: '失物招领', icon: '🔍', desc: '发布与查找失物' },
    { id: 's7', name: '校园资讯', icon: '📰', desc: '查看校园动态' },
    { id: 's8', name: '空教室', icon: '🏫', desc: '查询空闲教室' },
    { id: 's9', name: '校历', icon: '📆', desc: '查看学期安排' },
    { id: 's10', name: '网络报修', icon: '🔧', desc: '网络问题报修' }
  ];

  build() {
    Column() {
      // 导航栏
      Row() {
        BackButton()
        
        Text('更多服务')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(ColorConstants.TEXT_PRIMARY)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Blank().width(44)
      }
      .width('100%')
      .height(56)
      .padding({ left: 4, right: 16 })
      .backgroundColor(ColorConstants.BG_PAGE)

      // 服务列表
      List({ space: 12 }) {
        ForEach(this.services, (service: ServiceItem) => {
          ListItem() {
            this.ServiceCard(service)
          }
        }, (service: ServiceItem) => service.id)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }

  /**
   * 服务卡片组件
   */
  @Builder
  ServiceCard(service: ServiceItem) {
    Row() {
      // 图标
      Text(service.icon)
        .fontSize(32)
        .width(56)
        .height(56)
        .textAlign(TextAlign.Center)
        .backgroundColor(ColorConstants.BG_CARD)
        .borderRadius(12)

      // 文字信息
      Column() {
        Text(service.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(ColorConstants.TEXT_PRIMARY)
        
        Text(service.desc)
          .fontSize(13)
          .fontColor(ColorConstants.TEXT_TERTIARY)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      // 箭头
      Text('›')
        .fontSize(20)
        .fontColor(ColorConstants.TEXT_TERTIARY)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(ColorConstants.BG_CARD)
    .borderRadius(12)
    .onClick(() => {
      this.onServiceClick(service);
    })
  }

  /**
   * 服务点击处理
   */
  private onServiceClick(service: ServiceItem): void {
    // 根据服务ID跳转到对应页面
    switch (service.id) {
      case 's1': // 图书馆
        router.pushUrl({ url: 'pages/library/LibraryPage' });
        break;
      case 's2': // 课程表
        router.pushUrl({ url: 'pages/schedule/SchedulePage', params: { showBack: true } });
        break;
      case 's3': // 成绩查询
        CommonUtil.showToast('成绩查询功能开发中');
        break;
      case 's4': // 校园卡
        router.pushUrl({ url: 'pages/card/CardPage' });
        break;
      case 's5': // 校园活动
        router.pushUrl({ url: 'pages/activity/ActivityPage' });
        break;
      case 's6': // 失物招领
        router.pushUrl({ url: 'pages/lostfound/LostFoundPage' });
        break;
      case 's7': // 校园资讯
        router.pushUrl({ url: 'pages/news/NewsPage' });
        break;
      default:
        CommonUtil.showToast(`${service.name}功能开发中`);
        break;
    }
  }
}

/**
 * 服务项数据结构
 */
interface ServiceItem {
  id: string;
  name: string;
  icon: string;
  desc: string;
}
