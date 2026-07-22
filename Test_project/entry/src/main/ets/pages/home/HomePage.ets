import { HomeViewModel } from '../../viewmodel/HomeViewModel';
import { QuickEntryGrid } from '../../components/home/QuickEntryGrid';
import { TodayCourseCard } from '../../components/home/TodayCourseCard';
import { HeroCampusCard } from '../../components/home/HeroCampusCard';
import { QuickEntry } from '../../model/QuickEntry';
import { Course } from '../../model/Course';
import { NewsItem } from '../../model/News';
import { CardInfo } from '../../model/CampusCard';
import { ColorConstants, GradientColor } from '../../constant/ColorConstants';
import { CommonUtil } from '../../utils/CommonUtil';
import { DateUtil } from '../../utils/DateUtil';
import router from '@ohos.router';

/**
 * 分区标题组件（Section Title）
 * 左侧渐变色竖条 + 标题文字 + 右侧"更多"链接
 */
@Component
export struct SectionTitle {
  title: string = '';
  moreText: string = '更多 ›';
  showMore: boolean = true;

  onMoreClick?: () => void;

  build() {
    Row() {
      // 左侧渐变色竖条
      Column()
        .width(4)
        .height(16)
        .borderRadius(3)
        .linearGradient({
          direction: GradientDirection.Top,
          colors: [
            [ColorConstants.PRIMARY, 0.0],
            [ColorConstants.TEAL, 1.0]
          ]
        })
        .margin({ right: 8 })

      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(ColorConstants.TEXT_PRIMARY)
        .layoutWeight(1)

      if (this.showMore) {
        Text(this.moreText)
          .fontSize(11.5)
          .fontColor(ColorConstants.TEXT_TERTIARY)
          .onClick(() => {
            this.onMoreClick?.();
          })
      }
    }
    .width('100%')
    .padding({ left: 2, right: 2 })
  }
}

/**
 * 校园动态 Feed 卡片组件
 * 左渐变图标 + 中标题副标题 + 右箭头
 */
@Component
struct FeedCard {
  news!: NewsItem;
  index: number = 0;

  onItemClick?: (news: NewsItem) => void;

  @State isPressed: boolean = false;

  // 根据索引获取不同的渐变色
  private getGradient(): GradientColor {
    const gradients: GradientColor[] = [
      { start: '#FF8A8A', end: '#FF5A5A' },
      { start: '#3FDDB0', end: '#13B589' },
      { start: '#A98CF0', end: '#7B5AE0' },
      { start: '#FFC97A', end: '#FF9D2E' },
      { start: '#7AE8FF', end: '#45B3FF' }
    ];
    return gradients[this.index % gradients.length];
  }

  build() {
    Row({ space: 13 }) {
      // 左侧渐变缩略图
      Stack() {
        // 渐变背景
        Column()
          .width('100%')
          .height('100%')
          .linearGradient({
            direction: GradientDirection.LeftBottom,
            colors: [
              [this.getGradient().start, 0.0],
              [this.getGradient().end, 1.0]
            ]
          })

        // 光泽效果
        Column()
          .width('100%')
          .height('60%')
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [
              ['rgba(255,255,255,0.0)', 0.0],
              ['rgba(255,255,255,0.4)', 1.0]
            ]
          })

        // 图标
        Text(this.index % 3 === 0 ? '🍜' : this.index % 3 === 1 ? '📚' : '🎯')
          .fontSize(26)
      }
      .width(60)
      .height(60)
      .borderRadius(16)
      .clip(true)
      .flexShrink(0)

      // 中间内容
      Column({ space: 4 }) {
        // 分类标签
        Text(this.news.category || '通知')
          .fontSize(9)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getGradient().end)
          .backgroundColor(this.getGradient().start + '26')
          .padding({ left: 7, right: 7, top: 2, bottom: 2 })
          .borderRadius(6)
          .letterSpacing(0.5)

        // 标题
        Text(this.news.title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(ColorConstants.TEXT_PRIMARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        // 描述
        Text(this.news.summary || this.news.publishTime)
          .fontSize(11.5)
          .fontColor(ColorConstants.TEXT_SECONDARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 右侧箭头
      Text('\u203A')
        .fontSize(18)
        .fontColor(ColorConstants.TEXT_TERTIARY)
        .flexShrink(0)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(ColorConstants.BG_CARD)
    .borderRadius(26)
    .border({
      width: 1,
      color: ColorConstants.BORDER
    })
    .shadow({
      radius: 16,
      color: 'rgba(20, 40, 90, 0.08)',
      offsetX: 0,
      offsetY: 6
    })
    .scale({ x: this.isPressed ? 0.98 : 1, y: this.isPressed ? 0.98 : 1 })
    .opacity(this.isPressed ? 0.85 : 1)
    .animation({ duration: 200, curve: Curve.EaseInOut })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false;
        if (event.type === TouchType.Up) {
          this.onItemClick?.(this.news);
        }
      }
    })
  }
}

/**
 * 问候区组件（Greet Row）
 * 左侧：问候语 + 用户名高亮 + 日期副标题
 * 右侧：超椭圆头像（渐变背景 + 装饰环 + 未读消息小红点）
 */
@Component
struct GreetRow {
  @Prop userName: string = '';
  @Prop greeting: string = '早上好';
  @Prop dateSubtitle: string = '';

  onAvatarClick?: () => void;

  private get avatarText(): string {
    if (!this.userName) {
      return '👤';
    }
    const firstChar = this.userName.charAt(0);
    if (/[\u4e00-\u9fa5]/.test(firstChar)) {
      return firstChar;
    }
    return firstChar.toUpperCase();
  }

  build() {
    Row() {
      // 左侧：问候语 + 日期
      Column({ space: 4 }) {
        // 问候语 + 名字（名字高亮主色）
        Row({ space: 0 }) {
          Text(this.greeting + '，')
            .fontSize(22)
            .fontWeight(FontWeight.Medium)
            .fontColor(ColorConstants.TEXT_PRIMARY)

          if (this.userName) {
            Text(this.userName)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(ColorConstants.PRIMARY)
          }
        }
        .width('100%')

        // 日期副标题
        Text(this.dateSubtitle)
          .fontSize(13)
          .fontColor(ColorConstants.TEXT_SECONDARY)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 右侧：超椭圆头像（外层装饰环 + 内层渐变头像 + 未读小红点）
      Stack({ alignContent: Alignment.TopEnd }) {
        // 装饰性外环（半透明渐变边框）
        Column()
          .width(52)
          .height(52)
          .borderRadius(18)
          .linearGradient({
            direction: GradientDirection.LeftBottom,
            colors: [
              [ColorConstants.PRIMARY, 0.0],
              [ColorConstants.TEAL, 1.0]
            ]
          })
          .opacity(0.15)

        // 内层头像主体（渐变背景 + 姓名首字或默认图标）
        Column() {
          Text(this.avatarText)
            .fontSize(this.userName ? 22 : 18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .width(44)
        .height(44)
        .borderRadius(15)
        .linearGradient({
          direction: GradientDirection.LeftBottom,
          colors: [
            [ColorConstants.PRIMARY, 0.0],
            [ColorConstants.TEAL, 1.0]
          ]
        })
        .shadow({
          radius: 8,
          color: 'rgba(10, 89, 247, 0.25)',
          offsetX: 0,
          offsetY: 3
        })

        // 未读消息小红点（装饰）
        Column()
          .width(10)
          .height(10)
          .borderRadius(5)
          .backgroundColor(ColorConstants.ERROR)
          .border({ width: 2, color: '#FFFFFF' })
          .margin({ top: 0, right: 0 })
      }
      .width(52)
      .height(52)
      .onClick(() => {
        this.onAvatarClick?.();
      })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 12, bottom: 12 })
  }
}

@Entry
@Component
export struct HomePage {
  @State viewModel: HomeViewModel = new HomeViewModel();
  @State scrollY: number = 0;
  @State isRefreshing: boolean = false;
  @State isInitialLoading: boolean = true;

  @State greetingText: string = '';
  @State dateSubtitleText: string = '';
  @StorageLink('isLoggedIn') isLoggedIn: boolean = false;
  @StorageLink('userName') storedUserName: string = '';
  get userName(): string {
    if (this.viewModel.userInfo?.name) {
      return this.viewModel.userInfo.name;
    }
    return this.storedUserName || '';
  }

  aboutToAppear(): void {
    this.updateGreeting();
    this.viewModel.refresh();
    this.isInitialLoading = false;
  }

  // 更新问候语
  private updateGreeting(): void {
    this.greetingText = DateUtil.getGreeting();
    this.dateSubtitleText = DateUtil.getGreetDateSubtitle();
  }

  // 下拉刷新处理
  private async onRefresh(): Promise<void> {
    if (this.isRefreshing) return;
    this.isRefreshing = true;
    this.updateGreeting();
    await this.viewModel.refreshAsync();
    this.isRefreshing = false;
    CommonUtil.showToast('刷新成功');
  }

  @Builder
  RefreshIndicator() {
    Column() {
      if (this.isRefreshing) {
        // iOS风格刷新指示器
        Row() {
          // 加载动画 - 旋转的菊花
          Text('⟳')
            .fontSize(20)
            .fontColor(ColorConstants.PRIMARY)
            .rotate({ angle: this.isRefreshing ? 360 : 0 })
            .animation({
              duration: 800,
              curve: Curve.Linear,
              iterations: -1,
              playMode: PlayMode.Normal
            })

          Text('正在刷新...')
            .fontSize(14)
            .fontColor(ColorConstants.TEXT_SECONDARY)
            .margin({ left: 8 })
        }
        .padding({ top: 16, bottom: 8 })
      }
    }
    .width('100%')
  }

  @Builder
  SkeletonLoadingView() {
    Column({ space: 16 }) {
      // Hero 校园卡骨架
      Column()
        .width('100%')
        .height(240)
        .backgroundColor(ColorConstants.BG_TERTIARY)
        .borderRadius(26)

      // 快捷入口骨架
      Column() {
        Row() {
          ForEach([1, 2, 3, 4], (_: number, index: number) => {
            Column() {
              Circle()
                .width(48)
                .height(48)
                .fill(ColorConstants.BG_TERTIARY)
              Column()
                .width(40)
                .height(12)
                .backgroundColor(ColorConstants.BG_TERTIARY)
                .borderRadius(6)
                .margin({ top: 10 })
            }
            .width('25%')
            .padding({ top: 14, bottom: 14 })
          })
        }
        .width('100%')

        Divider()
          .color(ColorConstants.DIVIDER)
          .margin({ left: 16, right: 16 })

        Row() {
          ForEach([1, 2, 3, 4], (_: number, index: number) => {
            Column() {
              Circle()
                .width(48)
                .height(48)
                .fill(ColorConstants.BG_TERTIARY)
              Column()
                .width(40)
                .height(12)
                .backgroundColor(ColorConstants.BG_TERTIARY)
                .borderRadius(6)
                .margin({ top: 10 })
            }
            .width('25%')
            .padding({ top: 14, bottom: 14 })
          })
        }
        .width('100%')
      }
      .width('100%')
      .padding({ top: 4, bottom: 4 })
      .backgroundColor(ColorConstants.BG_CARD)
      .borderRadius(16)

      // 课程卡片骨架
      Column() {
        Row() {
          Column()
            .width(80)
            .height(16)
            .backgroundColor(ColorConstants.BG_TERTIARY)
            .borderRadius(8)
          Blank()
          Column()
            .width(60)
            .height(14)
            .backgroundColor(ColorConstants.BG_TERTIARY)
            .borderRadius(7)
        }
        .width('100%')
        .margin({ bottom: 12 })

        ForEach([1, 2, 3], (_: number, index: number) => {
          Row() {
            Column()
              .width(50)
              .height(12)
              .backgroundColor(ColorConstants.BG_TERTIARY)
              .borderRadius(6)
            Column()
              .width(4)
              .height('70%')
              .backgroundColor(ColorConstants.BG_TERTIARY)
              .borderRadius(2)
              .margin({ left: 14, right: 12 })
            Column() {
              Column()
                .width('60%')
                .height(14)
                .backgroundColor(ColorConstants.BG_TERTIARY)
                .borderRadius(7)
              Column()
                .width('40%')
                .height(12)
                .backgroundColor(ColorConstants.BG_TERTIARY)
                .borderRadius(6)
                .margin({ top: 8 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding({ top: 10, bottom: 10 })

          if (index < 2) {
            Divider()
              .color(ColorConstants.DIVIDER)
              .margin({ left: 76 })
          }
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(ColorConstants.BG_CARD)
      .borderRadius(16)

      // 公告卡片骨架
      Column() {
        Row() {
          Column()
            .width(80)
            .height(16)
            .backgroundColor(ColorConstants.BG_TERTIARY)
            .borderRadius(8)
          Blank()
          Column()
            .width(40)
            .height(14)
            .backgroundColor(ColorConstants.BG_TERTIARY)
            .borderRadius(7)
        }
        .width('100%')
        .margin({ bottom: 8 })

        ForEach([1, 2, 3, 4, 5], (_: number, index: number) => {
          Row() {
            Column() {
              Column()
                .width('80%')
                .height(14)
                .backgroundColor(ColorConstants.BG_TERTIARY)
                .borderRadius(7)
              Column()
                .width('30%')
                .height(12)
                .backgroundColor(ColorConstants.BG_TERTIARY)
                .borderRadius(6)
                .margin({ top: 6 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding({ top: 12, bottom: 12 })

          if (index < 4) {
            Divider()
              .color(ColorConstants.DIVIDER)
          }
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(ColorConstants.BG_CARD)
      .borderRadius(16)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 4, bottom: 20 })
  }

  build() {
    Column() {
      // 可滚动内容区域
      Scroll() {
        Column({ space: 16 }) {
          // 下拉刷新指示器占位
          this.RefreshIndicator()

          if (this.isInitialLoading) {
            // 骨架屏加载状态
            this.SkeletonLoadingView()
          } else {
            // 问候区
            GreetRow({
              userName: this.userName,
              greeting: this.greetingText,
              dateSubtitle: this.dateSubtitleText,
              onAvatarClick: () => {
                router.pushUrl({ url: 'pages/profile/ProfilePage' });
              }
            })
            .width('100%')
            .padding({ top: 4, bottom: 4 })

            // Hero 校园卡
            HeroCampusCard({
              cardInfo: this.viewModel.cardInfo,
              userInfo: this.viewModel.userInfo,
              schoolName: '华夏科技大学',
              onRechargeClick: () => {
                router.pushUrl({ url: 'pages/card/RechargePage' });
              },
              onBillClick: () => {
                router.pushUrl({ url: 'pages/card/RecordPage' });
              },
              onLostClick: () => {
                CommonUtil.showToast('挂失');
              }
            })
            .margin({ left: 16, right: 16 })

            // 常用服务分区
            Column({ space: 12 }) {
              // 分区标题
              SectionTitle({
                title: '常用服务',
                moreText: '更多 ›',
                onMoreClick: () => {
                  router.pushUrl({ url: 'pages/home/MoreServicesPage' });
                }
              })
              .padding({ left: 2, right: 2 })

              // 快捷入口卡片（单行布局）
              QuickEntryGrid({
                entries: this.viewModel.quickEntries,
                onItemClick: (entry: QuickEntry) => {
                  if (entry.id === 'qe2') {
                    // 课表 → 跳转课程表页（显示返回按钮）
                    router.pushUrl({ url: 'pages/schedule/SchedulePage', params: { showBack: true } });
                  } else {
                    CommonUtil.showToast(entry.name);
                  }
                }
              })
            }
            .width('100%')
            .margin({ left: 16, right: 16 })

            // 今日课程卡片
            TodayCourseCard({
              courses: this.viewModel.todayCourses,
              onCourseClick: (course: Course) => {
                router.pushUrl({ url: 'pages/schedule/CourseDetailPage', params: { id: course.id } });
              },
              onMoreClick: () => {
                router.pushUrl({ url: 'pages/schedule/SchedulePage' });
              }
            })

            // 校园动态
            Column({ space: 12 }) {
              // 分区标题
              SectionTitle({
                title: '校园动态',
                moreText: '更多 ›',
                onMoreClick: () => {
                  router.pushUrl({ url: 'pages/news/NewsPage' });
                }
              })
              .padding({ left: 2, right: 2 })

              // Feed 卡片列表
              Column({ space: 12 }) {
                ForEach(this.viewModel.noticeList.slice(0, 4), (news: NewsItem, index: number) => {
                  FeedCard({
                    news: news,
                    index: index,
                    onItemClick: (n: NewsItem) => {
                      router.pushUrl({ url: 'pages/news/NewsDetailPage', params: { id: n.id } });
                    }
                  })
                  .opacity(this.isInitialLoading ? 0 : 1)
                  .translate({ y: this.isInitialLoading ? 16 : 0 })
                  .animation({
                    duration: 600,
                    curve: Curve.Smooth,
                    delay: 450 + index * 80
                  })
                }, (news: NewsItem) => news.id)
              }
              .width('100%')
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
          }
        }
        .width('100%')
        .padding({ left: 0, right: 0, top: 0, bottom: 20 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .onScroll((xOffset: number, yOffset: number) => {
        this.scrollY = -yOffset;
      })
      // 下拉刷新 - 利用 onScrollEdge 检测
      .onScrollEdge((side: Edge) => {
        if (side === Edge.Top && !this.isRefreshing && !this.isInitialLoading) {
          // 用户拉到顶部，触发刷新
          this.onRefresh();
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }
}
