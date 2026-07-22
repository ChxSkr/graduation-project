import { ColorConstants } from '../../constant/ColorConstants';
import { ItemType } from '../../model/LostFound';
import { picker } from '@kit.CoreFileKit';
import { Logger } from '../../utils/Logger';

// 图片上传区域 - 九宫格
@Component
export struct ImageUploadGrid {
  @Link images: string[];
  maxCount: number = 9;

  // 选择图片
  private async pickImage(): Promise<void> {
    try {
      const photoPicker = new picker.PhotoViewPicker();
      const result = await photoPicker.select({
        maxSelectNumber: this.maxCount - this.images.length,
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE
      });
      
      if (result.photoUris && result.photoUris.length > 0) {
        for (const uri of result.photoUris) {
          if (this.images.length < this.maxCount) {
            this.images.push(uri);
          }
        }
        Logger.info(`Selected ${result.photoUris.length} images`);
      }
    } catch (e) {
      Logger.error('Failed to pick image: ' + JSON.stringify(e));
    }
  }

  @Builder
  ImageItem(uri: string, index: number) {
    Stack() {
      // 显示图片
      Image(uri)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .borderRadius(8)

      // 删除按钮
      Column() {
        Text('✕')
          .fontSize(12)
          .fontColor('#FFFFFF')
      }
      .width(18)
      .height(18)
      .backgroundColor('rgba(0, 0, 0, 0.6)')
      .borderRadius(9)
      .justifyContent(FlexAlign.Center)
      .position({ x: '100%', y: 0 })
      .translate({ x: -6, y: 6 })
      .zIndex(1)
      .onClick(() => {
        this.images.splice(index, 1);
      })
    }
    .width('100%')
    .aspectRatio(1)
  }

  @Builder
  AddButton() {
    Column() {
      Text('+')
        .fontSize(28)
        .fontColor(ColorConstants.TEXT_TERTIARY)
        .fontWeight(FontWeight.Lighter)
    }
    .width('100%')
    .aspectRatio(1)
    .backgroundColor(ColorConstants.BG_SECONDARY)
    .borderRadius(8)
    .justifyContent(FlexAlign.Center)
    .border({
      width: 1,
      color: ColorConstants.TEXT_QUATERNARY,
      style: BorderStyle.Dashed
    })
    .onClick(() => {
      this.pickImage();
    })
  }

  build() {
    Grid() {
      ForEach(this.images, (uri: string, index: number) => {
        GridItem() {
          this.ImageItem(uri, index)
        }
      }, (uri: string, index: number) => uri + index.toString())

      if (this.images.length < this.maxCount) {
        GridItem() {
          this.AddButton()
        }
      }
    }
    .columnsTemplate('1fr 1fr 1fr')
    .rowsGap(8)
    .columnsGap(8)
    .width('100%')
  }
}

// iOS 风格表单项 - 带左侧标签和右侧输入
@Component
export struct FormInputRow {
  label: string = '';
  placeholder: string = '';
  @Link value: string;
  isRequired: boolean = false;
  inputType: InputType = InputType.Normal;
  showError: boolean = false;
  errorMessage: string = '';

  build() {
    Column() {
      Row() {
        // 标签
        Text(this.label)
          .fontSize(15)
          .fontColor(ColorConstants.TEXT_PRIMARY)
          .width(80)

        if (this.isRequired) {
          Text('*')
            .fontSize(15)
            .fontColor(ColorConstants.IOS_RED)
            .margin({ right: 4 })
        }

        // 输入框
        TextInput({ placeholder: this.placeholder, text: this.value })
          .fontSize(15)
          .placeholderColor(ColorConstants.TEXT_TERTIARY)
          .backgroundColor(ColorConstants.TRANSPARENT)
          .layoutWeight(1)
          .type(this.inputType)
          .onChange((val: string) => {
            this.value = val;
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 14, bottom: 14 })

      // 错误提示
      if (this.showError && this.errorMessage) {
        Row() {
          Text('⚠️ ' + this.errorMessage)
            .fontSize(12)
            .fontColor(ColorConstants.IOS_RED)
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 8 })
      }
    }
    .width('100%')
    .backgroundColor(this.showError
      ? 'rgba(255, 59, 48, 0.05)'
      : ColorConstants.BG_CARD)
  }
}

// iOS 风格表单项 - 带左侧标签和右侧多行输入
@Component
export struct FormTextAreaRow {
  label: string = '';
  placeholder: string = '';
  @Link value: string;
  isRequired: boolean = false;
  maxHeight: number = 100;
  showError: boolean = false;
  errorMessage: string = '';

  build() {
    Column() {
      Row() {
        Text(this.label)
          .fontSize(15)
          .fontColor(ColorConstants.TEXT_PRIMARY)

        if (this.isRequired) {
          Text('*')
            .fontSize(15)
            .fontColor(ColorConstants.IOS_RED)
            .margin({ right: 4 })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 14 })

      TextArea({ placeholder: this.placeholder, text: this.value })
        .fontSize(15)
        .placeholderColor(ColorConstants.TEXT_TERTIARY)
        .backgroundColor(ColorConstants.TRANSPARENT)
        .width('100%')
        .height(this.maxHeight)
        .padding({ left: 12, right: 12 })
        .margin({ left: 4, right: 4, top: 8, bottom: 12 })
        .onChange((val: string) => {
          this.value = val;
        })

      // 错误提示
      if (this.showError && this.errorMessage) {
        Row() {
          Text('⚠️ ' + this.errorMessage)
            .fontSize(12)
            .fontColor(ColorConstants.IOS_RED)
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 8 })
      }
    }
    .width('100%')
    .backgroundColor(this.showError
      ? 'rgba(255, 59, 48, 0.05)'
      : ColorConstants.BG_CARD)
  }
}

// iOS 风格分组选择器行
@Component
export struct FormSelectRow {
  label: string = '';
  @Link selectedValue: string;
  options: string[] = [];
  isRequired: boolean = false;

  @State showPicker: boolean = false;

  build() {
    Column() {
      Row() {
        Text(this.label)
          .fontSize(15)
          .fontColor(ColorConstants.TEXT_PRIMARY)

        if (this.isRequired) {
          Text('*')
            .fontSize(15)
            .fontColor(ColorConstants.IOS_RED)
            .margin({ right: 4 })
        }

        Text(this.selectedValue || '请选择')
          .fontSize(15)
          .fontColor(this.selectedValue ? ColorConstants.TEXT_PRIMARY : ColorConstants.TEXT_TERTIARY)
          .layoutWeight(1)
          .textAlign(TextAlign.End)

        Text('›')
          .fontSize(18)
          .fontColor(ColorConstants.TEXT_TERTIARY)
          .fontWeight(FontWeight.Lighter)
          .margin({ left: 4 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 14, bottom: 14 })
      .backgroundColor(ColorConstants.BG_CARD)
      .onClick(() => {
        this.showPicker = !this.showPicker;
      })

      // 展开的选项
      if (this.showPicker) {
        Column() {
          ForEach(this.options, (opt: string) => {
            Row() {
              Text(opt)
                .fontSize(15)
                .fontColor(this.selectedValue === opt ? ColorConstants.IOS_BLUE : ColorConstants.TEXT_PRIMARY)
                .layoutWeight(1)

              if (this.selectedValue === opt) {
                Text('✓')
                  .fontSize(15)
                  .fontColor(ColorConstants.IOS_BLUE)
              }
            }
            .width('100%')
            .padding({ left: 32, right: 16, top: 12, bottom: 12 })
            .onClick(() => {
              this.selectedValue = opt;
              this.showPicker = false;
            })
          }, (opt: string) => opt)
        }
        .width('100%')
        .backgroundColor(ColorConstants.BG_TERTIARY)
      }
    }
    .width('100%')
  }
}

// iOS 风格 Segmented Control 类型切换
@Component
export struct TypeSegmentedControl {
  @Link selectedType: ItemType;
  @State containerWidth: number = 100; // 给个默认值避免初始闪烁

  build() {
    Stack() {
      // 1. 去掉冗余 Row，直接使用 Column 作为滑动块
      Column()
        .width('50%')
        .height('100%')
        .backgroundColor(ColorConstants.BG_CARD)
        .borderRadius(16)
        .shadow({
          radius: 2,
          color: 'rgba(0, 0, 0, 0.08)',
          offsetX: 0,
          offsetY: 1
        })
        .translate({
          // 2. 明确基于无 margin 的宽度计算（因为外层用了 padding）
          x: this.selectedType === 'lost' ? 0 : this.containerWidth * 0.5
        })
        .animation({
          duration: 250,
          curve: Curve.EaseOut
        })

      // 文字层（使用 Button 或加 stateStyles）
      Row() {
        Button('寻物启事')
          .layoutWeight(1)
          .height(36)
          .backgroundColor(Color.Transparent) // 透明背景，只保留文字
          .fontSize(14)
          .fontWeight(this.selectedType === 'lost' ? FontWeight.Medium : FontWeight.Regular)
          .fontColor(this.selectedType === 'lost' ? ColorConstants.TEXT_PRIMARY : ColorConstants.TEXT_SECONDARY)
          .onClick(() => this.selectedType = 'lost')
          // 加按压态效果
          .stateStyles({
            pressed: {
              .scale({ x: 0.95, y: 0.95 })
            }
          })

        Button('失物招领')
          .layoutWeight(1)
          .height(36)
          .backgroundColor(Color.Transparent)
          .fontSize(14)
          .fontWeight(this.selectedType === 'found' ? FontWeight.Medium : FontWeight.Regular)
          .fontColor(this.selectedType === 'found' ? ColorConstants.TEXT_PRIMARY : ColorConstants.TEXT_SECONDARY)
          .onClick(() => this.selectedType = 'found')
          .stateStyles({
            pressed: {
              .scale({ x: 0.95, y: 0.95 })
            }
          })
      }
      .width('100%')
      .height(36)
      // 3. 去掉 margin，统一由外层 Stack 控制内边距
    }
    .width('100%')
    .height(40)
    .padding({ left: 2, right: 2 }) // 用 padding 替代子组件的 margin
    .backgroundColor(ColorConstants.BG_SECONDARY)
    .borderRadius(20)
    .clip(true) // 关键：裁剪溢出内容
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.containerWidth = Number(newValue.width);
    })
  }
}

// 分组卡片容器
@Component
export struct FormGroupCard {
  title?: string = '';
  @BuilderParam content: () => void;

  build() {
    Column() {
      if (this.title && this.title.length > 0) {
        Text(this.title)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(ColorConstants.TEXT_SECONDARY)
          .width('100%')
          .padding({ left: 16, bottom: 8 })
          .textAlign(TextAlign.Start)
      }

      Column() {
        this.content()
      }
      .width('100%')
      .backgroundColor(ColorConstants.BG_CARD)
      .borderRadius(12)
      .clip(true)
    }
    .width('100%')
    .margin({ bottom: 20 })
  }
}
