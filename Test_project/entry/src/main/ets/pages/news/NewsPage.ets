import { NewsViewModel } from '../../viewmodel/NewsViewModel';
import { CategoryTabs } from '../../components/news/CategoryTabs';
import { NewsListItem } from '../../components/news/NewsListItem';
import { NewsItem } from '../../model/News';
import { ColorConstants } from '../../constant/ColorConstants';
import { CommonUtil } from '../../utils/CommonUtil';
import { DebounceUtil } from '../../utils/DebounceUtil';
import router from '@ohos.router';
import { LostFoundViewModel, Category as LostFoundCategory } from '../../viewmodel/LostFoundViewModel';
import { LostFoundItemCard } from '../../components/lostfound/LostFoundItem';
import { LostFoundItem, ItemType } from '../../model/LostFound';

// 寻物招领类型选项
interface TypeOption {
  type: ItemType;
  label: string;
}

@Entry
@Component
export struct NewsPage {
  @State viewModel: NewsViewModel = new NewsViewModel();
  @State lostFoundViewModel: LostFoundViewModel = new LostFoundViewModel();
  @State searchText: string = '';
  @State isSearchActive: boolean = false;
  // 当前页面类型：0-资讯，1-寻物招领
  @State currentTabIndex: number = 0;
  // 寻物招领类型：lost-寻物，found-招领
  @State lostFoundType: string = 'lost';
  @State showRefreshTip: boolean = false;
  @State refreshTipText: string = '';
  @State listOpacity: number = 1;
  private scroller: Scroller = new Scroller();
  private searchInputController: TextInputController = new TextInputController();

  aboutToAppear(): void {
    this.viewModel.loadNews();
  }

  @Builder
  SkeletonItem() {
    Row() {
      Column() {}
        .width(76)
        .height(76)
        .backgroundColor(ColorConstants.BG_SECONDARY)
        .borderRadius(8)
        .margin({ right: 12 })

      Column() {
        Column() {}
          .width('80%')
          .height(16)
          .backgroundColor(ColorConstants.BG_SECONDARY)
          .borderRadius(4)

        Column() {}
          .width('50%')
          .height(13)
          .backgroundColor(ColorConstants.BG_SECONDARY)
          .borderRadius(4)
          .margin({ top: 10 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
  }

  @Builder
  SkeletonList() {
    Column() {
      ForEach([1, 2, 3, 4, 5], (item: number) => {
        this.SkeletonItem()
        if (item < 5) {
          Divider()
            .color(ColorConstants.DIVIDER)
            .margin({ left: 108 })
            .strokeWidth(0.5)
        }
      }, (item: number) => item.toString())
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 4, bottom: 4 })
    .backgroundColor(ColorConstants.BG_CARD)
    .borderRadius(14)
    .opacity(0.6)
  }

  @Builder
  SearchBar() {
    Row() {
      Text('🔍')
        .fontSize(14)
        .margin({ right: 6 })
      TextInput({
        placeholder: '搜索',
        text: this.searchText,
        controller: this.searchInputController
      })
        .fontSize(16)
        .layoutWeight(1)
        .backgroundColor(ColorConstants.TRANSPARENT)
        .placeholderColor(ColorConstants.TEXT_TERTIARY)
        .key('news_search_input')
        .onChange((value: string) => {
          this.searchText = value;
          // 使用防抖延迟触发搜索，避免频繁请求
          DebounceUtil.debounce('news_search', () => {
            this.viewModel.setSearchKeyword(value);
          }, 300);
        })
        .onSubmit(() => {
          // 提交时立即执行搜索
          DebounceUtil.immediate('news_search', () => {
            this.viewModel.setSearchKeyword(this.searchText);
            if (this.searchText.trim()) {
              this.viewModel.addSearchHistory(this.searchText.trim());
            }
          });
        })
      if (this.searchText.length > 0) {
        Text('✕')
          .fontSize(14)
          .fontColor(ColorConstants.TEXT_TERTIARY)
          .width(20)
          .height(20)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.searchText = '';
            this.viewModel.setSearchKeyword('');
          })
      }
    }
    .width('100%')
    .height(36)
    .padding({ left: 10, right: 12 })
    .backgroundColor(ColorConstants.BG_SECONDARY)
    .borderRadius(10)
    .onClick(() => {
      if (!this.isSearchActive) {
        this.isSearchActive = true;
        // 延迟聚焦，等待 TextInput 渲染完成
        setTimeout(() => {
          this.getUIContext().getFocusController().requestFocus('news_search_input');
        }, 100);
      }
    })
  }

  @Builder
  SearchHistoryPanel() {
    Column() {
      // 搜索历史
      if (this.viewModel.searchHistory.length > 0) {
        Row() {
          Text('搜索历史')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(ColorConstants.TEXT_PRIMARY)
            .layoutWeight(1)
          Text('清除')
            .fontSize(13)
            .fontColor(ColorConstants.TEXT_TERTIARY)
            .onClick(() => {
              this.viewModel.clearSearchHistory();
            })
        }
        .width('100%')
        .margin({ bottom: 12 })

        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
          ForEach(this.viewModel.searchHistory, (keyword: string) => {
            Text(keyword)
              .fontSize(13)
              .fontColor(ColorConstants.TEXT_SECONDARY)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(ColorConstants.BG_SECONDARY)
              .borderRadius(16)
              .margin({ right: 8, bottom: 8 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .onClick(() => {
                this.searchText = keyword;
                this.viewModel.setSearchKeyword(keyword);
                this.viewModel.addSearchHistory(keyword);
              })
          }, (keyword: string) => keyword)
        }
        .width('100%')
      }

      // 热门搜索
      Row() {
        Text('🔥 热门搜索')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(ColorConstants.TEXT_PRIMARY)
      }
      .width('100%')
      .margin({ top: 16, bottom: 12 })

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(this.viewModel.hotSearches, (keyword: string, index: number) => {
          Row() {
            Text((index + 1).toString())
              .fontSize(11)
              .fontColor(index < 3 ? ColorConstants.IOS_RED : ColorConstants.TEXT_TERTIARY)
              .fontWeight(index < 3 ? FontWeight.Bold : FontWeight.Regular)
              .margin({ right: 4 })
            Text(keyword)
              .fontSize(13)
              .fontColor(ColorConstants.TEXT_SECONDARY)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(ColorConstants.BG_SECONDARY)
          .borderRadius(16)
          .margin({ right: 8, bottom: 8 })
          .onClick(() => {
            this.searchText = keyword;
            this.viewModel.setSearchKeyword(keyword);
            this.viewModel.addSearchHistory(keyword);
          })
        }, (keyword: string) => keyword)
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 20 })
  }

  @Builder
  EmptyState() {
    Column() {
      Text('🔍')
        .fontSize(64)
        .margin({ bottom: 16 })
      Text('没有找到相关资讯')
        .fontSize(16)
        .fontColor(ColorConstants.TEXT_SECONDARY)
      Text('换个关键词试试吧')
        .fontSize(14)
        .fontColor(ColorConstants.TEXT_TERTIARY)
        .margin({ top: 8 })
    }
    .width('100%')
    .height(300)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  LoadingMoreFooter() {
    Row() {
      if (this.viewModel.isLoadingMore) {
        Text('加载中...')
          .fontSize(13)
          .fontColor(ColorConstants.TEXT_TERTIARY)
      } else if (!this.viewModel.hasMore) {
        Text('没有更多了')
          .fontSize(13)
          .fontColor(ColorConstants.TEXT_TERTIARY)
      }
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  NewsListContent() {
    Column() {
      // iOS分组列表：白色圆角卡片容器
      Column() {
        ForEach(this.viewModel.getFilteredNews(), (news: NewsItem, index: number) => {
          NewsListItem({
            news: news,
            onNewsClick: (item: NewsItem) => {
              this.viewModel.incrementViews(item.id);
              router.pushUrl({ url: 'pages/news/NewsDetailPage', params: { id: item.id } });
            }
          })
          // 分隔线：左侧缩进对齐内容（iOS风格）
          if (index < this.viewModel.getFilteredNews().length - 1) {
            Divider()
              .color(ColorConstants.DIVIDER)
              .margin({ left: 108 })
              .strokeWidth(0.5)
          }
        }, (news: NewsItem) => news.id)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 4, bottom: 4 })
      .backgroundColor(ColorConstants.BG_CARD)
      .borderRadius(14)
      .opacity(this.listOpacity)
      .animation({
        duration: 300,
        curve: Curve.EaseInOut
      })

      // 加载更多底部
      this.LoadingMoreFooter()
    }
    .width('100%')
  }

  // 寻物招领列表内容
  @Builder
  LostFoundListContent() {
    Column() {
      Column() {
        ForEach(this.lostFoundViewModel.getFilteredItems(), (item: LostFoundItem, index: number) => {
          LostFoundItemCard({
            item: item,
            onCardClick: (clickedItem: LostFoundItem) => {
              router.pushUrl({ url: 'pages/lostfound/LostFoundDetailPage', params: { id: clickedItem.id } });
            }
          })
          if (index < this.lostFoundViewModel.getFilteredItems().length - 1) {
            Divider()
              .color(ColorConstants.DIVIDER)
              .strokeWidth(0.5)
          }
        }, (item: LostFoundItem) => item.id)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 4, bottom: 4 })
      .backgroundColor(ColorConstants.BG_CARD)
      .borderRadius(14)
      .opacity(this.listOpacity)
      .animation({
        duration: 300,
        curve: Curve.EaseInOut
      })
    }
    .width('100%')
  }

  // 寻物招领空状态
  @Builder
  LostFoundEmptyState() {
    Column() {
      Column() {
        Text('🔍')
          .fontSize(48)
      }
      .width(80)
      .height(80)
      .borderRadius(40)
      .backgroundColor(ColorConstants.BG_TERTIARY)
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 16 })

      Text(this.searchText.length > 0
        ? '没有找到相关结果'
        : (this.lostFoundType === 'lost' ? '暂无寻物启事' : '暂无招领启事'))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(ColorConstants.TEXT_PRIMARY)
        .margin({ bottom: 8 })

      Text(this.searchText.length > 0
        ? '试试其他关键词吧'
        : '快来发布第一条信息吧~')
        .fontSize(14)
        .fontColor(ColorConstants.TEXT_SECONDARY)
    }
    .width('100%')
    .padding({ top: 60, bottom: 60 })
  }

  build() {
    Column() {
      // iOS风格导航区域：大标题 + 搜索栏
      Column() {
        if (!this.isSearchActive) {
          // 大标题区域
          Column() {
            // 类型切换 Tab
            Row() {
              ForEach(['资讯', '寻物招领'], (tab: string) => {
                Text(tab)
                  .fontSize(this.currentTabIndex === ['资讯', '寻物招领'].indexOf(tab) ? 34 : 20)
                  .fontWeight(this.currentTabIndex === ['资讯', '寻物招领'].indexOf(tab) ? FontWeight.Bold : FontWeight.Regular)
                  .fontColor(this.currentTabIndex === ['资讯', '寻物招领'].indexOf(tab) ? ColorConstants.TEXT_PRIMARY : ColorConstants.TEXT_TERTIARY)
                  .onClick(() => {
                    const idx = ['资讯', '寻物招领'].indexOf(tab);
                    if (this.currentTabIndex !== idx) {
                      this.currentTabIndex = idx;
                      this.searchText = '';
                      this.scroller.scrollEdge(Edge.Top);
                    }
                  })
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Bottom)
            .height(40)
            .margin({ bottom: 12 })
          }
          .width('100%')
        }

        // 搜索栏 + 取消按钮
        Row() {
          Column() {
            this.SearchBar()
          }
          .layoutWeight(1)

          if (this.isSearchActive) {
            Text('取消')
              .fontSize(16)
              .fontColor(ColorConstants.PRIMARY)
              .margin({ left: 12 })
              .onClick(() => {
                this.isSearchActive = false;
                this.searchText = '';
                this.viewModel.setSearchKeyword('');
              })
          }
        }
        .width('100%')

        // 分类分段控件（非搜索状态显示）
        if (!this.isSearchActive) {
          if (this.currentTabIndex === 0) {
            // 资讯分类
            CategoryTabs({
              categories: this.viewModel.categories,
              currentCategory: this.viewModel.currentCategory,
              onSelect: (catId: string) => {
                this.listOpacity = 0;
                setTimeout(() => {
                  this.viewModel.setCategory(catId);
                  this.scroller.scrollEdge(Edge.Top);
                  this.listOpacity = 1;
                }, 150);
              }
            })
            .margin({ top: 16 })
          } else {
            // 寻物招领类型切换
            Row() {
              ForEach([
                { type: 'lost', label: '寻物' },
                { type: 'found', label: '招领' }
              ] as TypeOption[], (item: TypeOption) => {
                Text(item.label)
                  .fontSize(15)
                  .fontWeight(this.lostFoundType === item.type ? FontWeight.Medium : FontWeight.Regular)
                  .fontColor(this.lostFoundType === item.type ? '#007AFF' : '#5A6788')
                  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                  .backgroundColor(this.lostFoundType === item.type ? 'rgba(0, 122, 255, 0.1)' : ColorConstants.BG_CARD)
                  .borderRadius(20)
                  .onClick(() => {
                    this.lostFoundType = item.type;
                    this.lostFoundViewModel.setType(item.type);
                    this.scroller.scrollEdge(Edge.Top);
                  })
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .margin({ top: 16 })
          }
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 8, bottom: 12 })
      .backgroundColor(ColorConstants.BG_PAGE)

      // 刷新提示
      if (this.showRefreshTip) {
        Text(this.refreshTipText)
          .fontSize(13)
          .fontColor(ColorConstants.IOS_GREEN)
          .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          .backgroundColor(ColorConstants.BG_CARD)
          .borderRadius(20)
          .margin({ bottom: 8 })
          .transition(TransitionEffect.OPACITY.combine(TransitionEffect.translate({ y: -20 })))
          .animation({ duration: 300 })
      }

      // 搜索状态：搜索历史 + 结果
      if (this.isSearchActive && !this.searchText.trim()) {
        Scroll() {
          this.SearchHistoryPanel()
        }
        .layoutWeight(1)
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      } else {
        // 列表区域
        Stack({ alignContent: Alignment.TopStart }) {
          List({ scroller: this.scroller }) {
            if (this.currentTabIndex === 0) {
              // 资讯列表
              // 骨架屏
              if (this.viewModel.isLoading) {
                ListItem() {
                  this.SkeletonList()
                }
                .width('100%')
                .padding({ left: 20, right: 20, top: 8, bottom: 20 })
              }
              // 空状态
              else if (this.viewModel.getFilteredNews().length === 0) {
                ListItem() {
                  this.EmptyState()
                }
                .width('100%')
              }
              // 资讯列表
              else {
                ListItem() {
                  this.NewsListContent()
                }
                .width('100%')
                .padding({ left: 20, right: 20, top: 8, bottom: 20 })
              }
            } else {
              // 寻物招领列表
              if (this.lostFoundViewModel.isLoading) {
                ListItem() {
                  this.SkeletonList()
                }
                .width('100%')
                .padding({ left: 20, right: 20, top: 8, bottom: 20 })
              } else if (this.lostFoundViewModel.getFilteredItems().length === 0) {
                ListItem() {
                  this.LostFoundEmptyState()
                }
                .width('100%')
              } else {
                ListItem() {
                  this.LostFoundListContent()
                }
                .width('100%')
                .padding({ left: 20, right: 20, top: 8, bottom: 20 })
              }
            }
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .onReachEnd(() => {
            if (this.currentTabIndex === 0 && !this.isSearchActive && this.viewModel.getFilteredNews().length > 0) {
              this.viewModel.loadMore();
            }
          })

          // FAB 发布按钮（寻物招领时显示）
          if (this.currentTabIndex === 1) {
            Column() {
              Text('发布')
                .fontSize(16)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Medium)
            }
            .width(80)
            .height(40)
            .borderRadius(20)
            .backgroundColor(ColorConstants.IOS_BLUE)
            .justifyContent(FlexAlign.Center)
            .shadow({ radius: 8, color: 'rgba(0,0,0,0.15)', offsetX: 0, offsetY: 4 })
            .opacity(0.85)
            .position({ x: '50%', y: '100%' })
            .markAnchor({ x: 40, y: 64 })
            .onClick(() => {
              CommonUtil.showToast('发布功能开发中');
            })
          }
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }
}
