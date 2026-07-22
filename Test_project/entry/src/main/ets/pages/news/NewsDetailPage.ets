import { NewsItem } from '../../model/News';
import { ColorConstants } from '../../constant/ColorConstants';
import { CommonUtil } from '../../utils/CommonUtil';
import { BackButton } from '../../components/common/BackButton';
import router from '@ohos.router';

@Entry
@Component
export struct NewsDetailPage {
  @State news: NewsItem | null = null;
  @State navOpacity: number = 0;
  @State titleOpacity: number = 0;
  @State isLiked: boolean = false;
  @State likeCount: number = 0;
  @State isFavorited: boolean = false;
  @State favoriteCount: number = 0;
  @State likeScale: number = 1;
  @State likePlusOne: boolean = false;
  @State favoriteScale: number = 1;
  @State favoritePlusOne: boolean = false;
  @State commentCount: number = 0;
  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    // 模拟初始化数据
    if (this.news) {
      this.likeCount = Math.floor(Math.random() * 500) + 100;
      this.favoriteCount = Math.floor(Math.random() * 200) + 50;
      this.commentCount = Math.floor(Math.random() * 100) + 20;
    }
  }

  handleLike(): void {
    this.isLiked = !this.isLiked;
    if (this.isLiked) {
      this.likeCount++;
      this.likeScale = 1.3;
      this.likePlusOne = true;
      setTimeout(() => {
        this.likeScale = 1;
      }, 200);
      setTimeout(() => {
        this.likePlusOne = false;
      }, 800);
    } else {
      this.likeCount--;
      this.likeScale = 0.9;
      setTimeout(() => {
        this.likeScale = 1;
      }, 200);
    }
    CommonUtil.showToast(this.isLiked ? '点赞成功' : '已取消点赞');
  }

  handleFavorite(): void {
    this.isFavorited = !this.isFavorited;
    if (this.isFavorited) {
      this.favoriteCount++;
      this.favoriteScale = 1.3;
      this.favoritePlusOne = true;
      setTimeout(() => {
        this.favoriteScale = 1;
      }, 200);
      setTimeout(() => {
        this.favoritePlusOne = false;
      }, 800);
    } else {
      this.favoriteCount--;
      this.favoriteScale = 0.9;
      setTimeout(() => {
        this.favoriteScale = 1;
      }, 200);
    }
    CommonUtil.showToast(this.isFavorited ? '已收藏' : '已取消收藏');
  }

  handleShare(): void {
    CommonUtil.showToast('分享功能开发中');
  }

  handleComment(): void {
    CommonUtil.showToast('评论功能开发中');
  }

  handleBack(): void {
    router.back();
  }

  @Builder
  NavBar() {
    Stack({ alignContent: Alignment.Center }) {
      // 背景（毛玻璃效果）
      Row() {}
        .width('100%')
        .height('100%')
        .backgroundColor(`rgba(247, 247, 247, ${this.navOpacity * 0.92})`)
        .backdropBlur(this.navOpacity * 20)

      // 底部细线
      Column() {}
        .width('100%')
        .height(0.5)
        .backgroundColor(`rgba(60, 60, 67, ${this.navOpacity * 0.29})`)
        .position({ y: '100%' })

      // 标题
      Text(this.news ? this.news.title : '')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(ColorConstants.TEXT_PRIMARY)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('60%')
        .textAlign(TextAlign.Center)
        .opacity(this.titleOpacity)
        .animation({ duration: 200, curve: Curve.EaseInOut })

      // 左右按钮
      Row() {
        // 返回按钮
        BackButton({ style: 'symbol' })

        Blank()

        // 分享按钮
        Text('分享')
          .fontSize(15)
          .fontWeight(FontWeight.Regular)
          .fontColor(ColorConstants.PRIMARY)
          .width(60)
          .height(44)
          .textAlign(TextAlign.End)
          .onClick(() => {
            this.handleShare();
          })
      }
      .width('100%')
      .padding({ left: 8, right: 16 })
    }
    .width('100%')
    .height(56)
    .position({ x: 0, y: 0 })
    .zIndex(10)
  }

  @Builder
  AuthorInfo() {
    Row() {
      // 头像
      Column() {
        Text(this.news ? this.news.author.charAt(0) : '')
          .fontSize(14)
          .fontColor(ColorConstants.BG_CARD)
          .fontWeight(FontWeight.Medium)
      }
      .width(36)
      .height(36)
      .backgroundColor(ColorConstants.PRIMARY)
      .borderRadius(18)
      .justifyContent(FlexAlign.Center)
      .margin({ right: 10 })

      Column() {
        Text(this.news ? this.news.author : '')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(ColorConstants.TEXT_PRIMARY)

        Row() {
          Text(this.news ? this.news.publishTime : '')
            .fontSize(12)
            .fontColor(ColorConstants.TEXT_TERTIARY)

          Text('·')
            .fontSize(12)
            .fontColor(ColorConstants.TEXT_TERTIARY)
            .margin({ left: 6, right: 6 })

          Text((this.news ? this.news.views : 0) + ' 阅读')
            .fontSize(12)
            .fontColor(ColorConstants.TEXT_TERTIARY)
        }
        .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .margin({ top: 16, bottom: 20 })
  }

  @Builder
  ContentBody() {
    Column() {
      // 封面图
      Column() {
        Text('📰')
          .fontSize(56)
      }
      .width('100%')
      .height(200)
      .backgroundColor(ColorConstants.PRIMARY_LIGHT)
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 20 })

      // 正文段落
      Text(this.news ? this.news.content : '')
        .fontSize(16)
        .fontColor(ColorConstants.TEXT_PRIMARY)
        .width('100%')
        .lineHeight(26)
        .textIndent(32)

      // 图文混排占位 - 图片1
      Column() {
        Text('🖼️')
          .fontSize(40)
        Text('配图说明文字')
          .fontSize(12)
          .fontColor(ColorConstants.TEXT_TERTIARY)
          .margin({ top: 8 })
      }
      .width('100%')
      .height(160)
      .backgroundColor(ColorConstants.BG_SECONDARY)
      .borderRadius(10)
      .justifyContent(FlexAlign.Center)
      .margin({ top: 16, bottom: 16 })

      // 第二段落
      Text('校园资讯作为校园生活的重要组成部分，承载着信息传递、文化传播和师生交流的重要使命。随着数字化校园建设的不断推进，资讯获取的方式也在不断革新，从传统的公告栏、校报到如今的移动端App，信息传播的速度和覆盖面都得到了极大提升。')
        .fontSize(16)
        .fontColor(ColorConstants.TEXT_PRIMARY)
        .width('100%')
        .lineHeight(26)
        .textIndent(32)

      // 图文混排占位 - 图片2
      Column() {
        Text('🎓')
          .fontSize(40)
        Text('校园活动精彩瞬间')
          .fontSize(12)
          .fontColor(ColorConstants.TEXT_TERTIARY)
          .margin({ top: 8 })
      }
      .width('100%')
      .height(160)
      .backgroundColor(ColorConstants.BG_SECONDARY)
      .borderRadius(10)
      .justifyContent(FlexAlign.Center)
      .margin({ top: 16, bottom: 16 })

      // 第三段落
      Text('希望每一位同学都能在校园资讯中找到自己感兴趣的内容，积极参与校园活动，丰富自己的大学生活。如有任何问题或建议，欢迎通过App内反馈渠道与我们联系。')
        .fontSize(16)
        .fontColor(ColorConstants.TEXT_PRIMARY)
        .width('100%')
        .lineHeight(26)
        .textIndent(32)

      // 文末留白
      Column() {}
        .width('100%')
        .height(30)
    }
    .width('100%')
  }

  @Builder
  BottomBar() {
    Column() {
      // 顶部分隔线
      Divider()
        .color(ColorConstants.DIVIDER)
        .strokeWidth(0.5)
        .width('100%')

      Row() {
        // 点赞
        Column() {
          Stack({ alignContent: Alignment.Center }) {
            Text(this.isLiked ? '❤️' : '🤍')
              .fontSize(22)
              .scale({ x: this.likeScale, y: this.likeScale })
              .animation({ duration: 200, curve: Curve.EaseOut })

            if (this.likePlusOne) {
              Text('+1')
                .fontSize(12)
                .fontColor(ColorConstants.IOS_RED)
                .fontWeight(FontWeight.Bold)
                .translate({ y: -20 })
                .opacity(0)
                .animation({
                  duration: 600,
                  curve: Curve.EaseOut,
                  onFinish: () => {}
                })
            }
          }
          .width(32)
          .height(32)

          Text(this.likeCount.toString())
            .fontSize(11)
            .fontColor(this.isLiked ? ColorConstants.IOS_RED : ColorConstants.TEXT_SECONDARY)
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.handleLike();
        })

        // 收藏
        Column() {
          Stack({ alignContent: Alignment.Center }) {
            Text(this.isFavorited ? '⭐' : '☆')
              .fontSize(22)
              .fontColor(this.isFavorited ? ColorConstants.IOS_ORANGE : ColorConstants.TEXT_SECONDARY)
              .scale({ x: this.favoriteScale, y: this.favoriteScale })
              .animation({ duration: 200, curve: Curve.EaseOut })

            if (this.favoritePlusOne) {
              Text('+1')
                .fontSize(12)
                .fontColor(ColorConstants.IOS_ORANGE)
                .fontWeight(FontWeight.Bold)
                .translate({ y: -20 })
                .opacity(0)
            }
          }
          .width(32)
          .height(32)

          Text(this.favoriteCount.toString())
            .fontSize(11)
            .fontColor(this.isFavorited ? ColorConstants.IOS_ORANGE : ColorConstants.TEXT_SECONDARY)
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.handleFavorite();
        })

        // 评论
        Column() {
          Text('💬')
            .fontSize(22)
          Text(this.commentCount.toString())
            .fontSize(11)
            .fontColor(ColorConstants.TEXT_SECONDARY)
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.handleComment();
        })

        // 分享
        Column() {
          Text('↗️')
            .fontSize(22)
          Text('分享')
            .fontSize(11)
            .fontColor(ColorConstants.TEXT_SECONDARY)
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.handleShare();
        })
      }
      .width('100%')
      .height(56)
      .padding({ left: 10, right: 10 })

      // 底部安全区
      Column() {}
        .width('100%')
        .height(34)
    }
    .width('100%')
    .backgroundColor('rgba(248, 248, 248, 0.92)')
    .backdropBlur(20)
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 主内容区
      Column() {
        if (this.news) {
          List({ scroller: this.scroller }) {
            ListItem() {
              Column() {
                // 顶部导航占位（透明，让内容延伸到顶部）
                Column() {}
                  .width('100%')
                  .height(56)

                // 大标题
                Text(this.news.title)
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(ColorConstants.TEXT_PRIMARY)
                  .width('100%')
                  .lineHeight(30)

                // 作者信息行
                this.AuthorInfo()

                // 正文内容
                this.ContentBody()

                // 底部操作栏占位
                Column() {}
                  .width('100%')
                  .height(100)
              }
              .width('100%')
              .padding({ left: 20, right: 20, top: 0, bottom: 0 })
            }
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .onScroll((xOffset: number, yOffset: number) => {
            // 计算导航栏透明度
            const scrollY = Math.abs(yOffset);
            const maxScroll = 80;
            let opacity = scrollY / maxScroll;
            opacity = Math.min(1, Math.max(0, opacity));
            this.navOpacity = opacity;
            // 标题在滚动一定距离后渐显
            const titleMaxScroll = 100;
            let titleOp = (scrollY - 40) / (titleMaxScroll - 40);
            titleOp = Math.min(1, Math.max(0, titleOp));
            this.titleOpacity = titleOp;
          })

          // 底部操作栏
          this.BottomBar()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ColorConstants.BG_CARD)

      // 顶部导航栏（悬浮）
      this.NavBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_CARD)
  }
}
