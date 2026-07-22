import { LostFoundViewModel } from '../../viewmodel/LostFoundViewModel';
import { LostFoundItem, ItemType } from '../../model/LostFound';
import { ColorConstants } from '../../constant/ColorConstants';
import { CommonUtil } from '../../utils/CommonUtil';
import router from '@ohos.router';
import {
  ImageUploadGrid,
  FormInputRow,
  FormTextAreaRow,
  FormSelectRow,
  TypeSegmentedControl,
  FormGroupCard
} from '../../components/lostfound/PublishForm';

@Entry
@Component
export struct PublishPage {
  @State viewModel: LostFoundViewModel = new LostFoundViewModel();
  @State itemType: ItemType = 'lost';
  @State title: string = '';
  @State description: string = '';
  @State location: string = '';
  @State time: string = '';
  @State contact: string = '';
  @State category: string = '';
  @State images: string[] = [];
  @State isSubmitting: boolean = false;
  @State submitPressed: boolean = false;

  // 错误状态
  @State titleError: boolean = false;
  @State locationError: boolean = false;
  @State contactError: boolean = false;
  @State categoryError: boolean = false;

  private categories: string[] = ['证件', '电子产品', '钥匙', '书籍', '其他'];

  aboutToAppear(): void {
    // 发布页不需要预加载列表
  }

  // 返回上一页
  private goBack(): void {
    router.back();
  }

  // 表单验证
  private validateForm(): boolean {
    let isValid = true;

    if (!this.title.trim()) {
      this.titleError = true;
      isValid = false;
    } else {
      this.titleError = false;
    }

    if (!this.location.trim()) {
      this.locationError = true;
      isValid = false;
    } else {
      this.locationError = false;
    }

    if (!this.contact.trim()) {
      this.contactError = true;
      isValid = false;
    } else {
      this.contactError = false;
    }

    if (!this.category) {
      this.categoryError = true;
      isValid = false;
    } else {
      this.categoryError = false;
    }

    if (!isValid) {
      CommonUtil.showToast('请完善必填信息');
    }

    return isValid;
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航栏（iOS风格）
        Row() {
          Text('取消')
            .fontSize(16)
            .fontColor(ColorConstants.IOS_BLUE)
            .width(60)
            .onClick(() => {
              this.goBack();
            })

          Text('发布信息')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(ColorConstants.TEXT_PRIMARY)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Text('发布')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.isSubmitting ? ColorConstants.TEXT_TERTIARY : ColorConstants.IOS_BLUE)
            .width(60)
            .textAlign(TextAlign.End)
            .onClick(() => {
              if (!this.isSubmitting) {
                this.submit();
              }
            })
        }
        .width('100%')
        .height(50)
        .padding({ left: 16, right: 16 })
        .backgroundColor(ColorConstants.NAV_BAR_BG)
        .border({
          width: { bottom: 0.5 },
          color: 'rgba(0, 0, 0, 0.1)'
        })

        Scroll() {
          Column() {
            // 类型切换 Segmented Control
            FormGroupCard({ title: '信息类型' }) {
              Column() {
                TypeSegmentedControl({ selectedType: $itemType })
              }
              .padding(16)
              .width('100%')
            }

            // 图片上传
            FormGroupCard({ title: '添加图片（选填）' }) {
              Column() {
                ImageUploadGrid({
                  images: $images,
                  maxCount: 9
                })
              }
              .padding(16)
              .width('100%')
            }

            // 基本信息组
            FormGroupCard({ title: '基本信息' }) {
              Column() {
                FormInputRow({
                  label: '标题',
                  placeholder: '请输入物品名称或简要描述',
                  value: $title,
                  isRequired: true,
                  showError: this.titleError,
                  errorMessage: '请输入标题'
                })

                Divider()
                  .color(ColorConstants.DIVIDER)
                  .margin({ left: 16 })

                FormSelectRow({
                  label: '分类',
                  selectedValue: $category,
                  options: this.categories,
                  isRequired: true
                })
                // 分类错误提示
                if (this.categoryError) {
                  Row() {
                    Text('⚠️ 请选择物品分类')
                      .fontSize(12)
                      .fontColor(ColorConstants.IOS_RED)
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, bottom: 8 })
                }

                Divider()
                  .color(ColorConstants.DIVIDER)
                  .margin({ left: 16 })

                FormInputRow({
                  label: '地点',
                  placeholder: this.itemType === 'lost' ? '请输入丢失地点' : '请输入拾到地点',
                  value: $location,
                  isRequired: true,
                  showError: this.locationError,
                  errorMessage: '请输入地点'
                })

                Divider()
                  .color(ColorConstants.DIVIDER)
                  .margin({ left: 16 })

                FormInputRow({
                  label: '时间',
                  placeholder: this.itemType === 'lost' ? '请输入丢失时间' : '请输入拾到时间',
                  value: $time,
                  isRequired: false
                })
              }
              .width('100%')
            }

            // 联系方式组
            FormGroupCard({ title: '联系方式' }) {
              Column() {
                FormInputRow({
                  label: '联系电话',
                  placeholder: '请输入手机号或微信号',
                  value: $contact,
                  isRequired: true,
                  inputType: InputType.PhoneNumber,
                  showError: this.contactError,
                  errorMessage: '请输入联系方式'
                })
              }
              .width('100%')
            }

            // 详细描述组
            FormGroupCard({ title: '详细描述' }) {
              Column() {
                FormTextAreaRow({
                  label: '物品描述',
                  placeholder: this.itemType === 'lost'
                    ? '请详细描述物品特征、颜色、品牌等信息，帮助他人识别...'
                    : '请详细描述物品特征、颜色、品牌等信息，方便失主认领...',
                  value: $description,
                  isRequired: false,
                  maxHeight: 120
                })
              }
              .width('100%')
            }

            // 底部发布按钮
            Column() {
              Text(this.isSubmitting ? '发布中...' : '立即发布')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .width('100%')
                .height(48)
                .textAlign(TextAlign.Center)
                .backgroundColor(this.isSubmitting
                  ? ColorConstants.TEXT_TERTIARY
                  : ColorConstants.IOS_BLUE)
                .borderRadius(24)
                .scale({
                  x: this.submitPressed ? 0.98 : 1.0,
                  y: this.submitPressed ? 0.98 : 1.0
                })
                .opacity(this.submitPressed ? 0.8 : 1.0)
                .animation({
                  duration: 150,
                  curve: Curve.EaseInOut
                })
                .onTouch((event: TouchEvent) => {
                  if (event.type === TouchType.Down && !this.isSubmitting) {
                    this.submitPressed = true;
                  } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                    this.submitPressed = false;
                  }
                })
                .onClick(() => {
                  if (!this.isSubmitting) {
                    this.submit();
                  }
                })
            }
            .width('100%')
            .padding({ top: 8, bottom: 32 })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .backgroundColor(ColorConstants.BG_PAGE)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ColorConstants.BG_PAGE)

      // 加载遮罩
      if (this.isSubmitting) {
        Stack({ alignContent: Alignment.Center }) {
          Column() {
            Column() {
              // 加载指示器
              Text('⏳')
                .fontSize(32)
                .margin({ bottom: 12 })

              Text('发布中...')
                .fontSize(14)
                .fontColor(ColorConstants.TEXT_PRIMARY)
            }
            .padding(24)
            .backgroundColor(ColorConstants.BG_CARD)
            .borderRadius(12)
            .shadow({
              radius: 20,
              color: 'rgba(0, 0, 0, 0.1)',
              offsetX: 0,
              offsetY: 4
            })
          }
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.2)')
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(100)
      }
    }
    .width('100%')
    .height('100%')
  }

  private async submit(): Promise<void> {
    if (!this.validateForm()) {
      return;
    }

    this.isSubmitting = true;
    try {
      const item: LostFoundItem = {
        id: '',
        type: this.itemType,
        title: this.title.trim(),
        description: this.description.trim(),
        location: this.location.trim(),
        time: this.time.trim(),
        contact: this.contact.trim(),
        category: this.category,
        images: this.images,
        status: 'active',
        publishTime: ''
      };

      const success = await this.viewModel.publishItem(item);
      if (success) {
        CommonUtil.showToast('发布成功');
        // 发布成功后返回上一页
        setTimeout(() => {
          this.goBack();
        }, 1000);
      } else {
        CommonUtil.showToast('发布失败，请重试');
      }
    } finally {
      this.isSubmitting = false;
    }
  }
}
