import { Course } from '../../model/Course';
import { ColorConstants } from '../../constant/ColorConstants';
import { CommonUtil } from '../../utils/CommonUtil';
import { ScheduleViewModel } from '../../viewmodel/ScheduleViewModel';
import router from '@ohos.router';

@Entry
@Component
export struct AddCoursePage {
  @State viewModel: ScheduleViewModel = new ScheduleViewModel();
  @State courseName: string = '';
  @State teacher: string = '';
  @State classroom: string = '';
  @State selectedDay: number = 1;
  @State startSection: number = 1;
  @State endSection: number = 2;
  @State weekStart: number = 1;
  @State weekEnd: number = 16;
  @State credit: number = 2;
  @State remark: string = '';
  @State colorIndex: number = 0;
  @State isSaving: boolean = false;

  private weekDays: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  private colors: string[] = ColorConstants.COURSE_COLORS;

  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor(ColorConstants.TEXT_SECONDARY)
          .width(60)
          .onClick(() => {
            // 返回
          })
        Text('添加课程')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(ColorConstants.TEXT_PRIMARY)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('保存')
          .fontSize(16)
          .fontColor(ColorConstants.PRIMARY)
          .width(60)
          .textAlign(TextAlign.End)
          .onClick(() => {
            this.saveCourse();
          })
      }
      .width('100%')
      .height(50)
      .padding({ left: 16, right: 16 })
      .backgroundColor(ColorConstants.BG_CARD)

      Scroll() {
        Column() {
          // 课程名称
          Column() {
            Text('课程名称')
              .fontSize(13)
              .fontColor(ColorConstants.TEXT_SECONDARY)
              .margin({ bottom: 8 })
            TextInput({ placeholder: '请输入课程名称', text: this.courseName })
              .fontSize(16)
              .fontColor(ColorConstants.TEXT_PRIMARY)
              .onChange((value: string) => {
                this.courseName = value;
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(ColorConstants.BG_CARD)
          .borderRadius(12)
          .margin({ bottom: 12 })

          // 基本信息
          Column() {
            Row() {
              Text('任课教师')
                .fontSize(14)
                .fontColor(ColorConstants.TEXT_PRIMARY)
                .width(80)
              TextInput({ placeholder: '请输入教师姓名', text: this.teacher })
                .fontSize(14)
                .layoutWeight(1)
                .onChange((val: string) => { this.teacher = val; })
            }
            .width('100%')
            .padding({ top: 12, bottom: 12 })
            Divider().color(ColorConstants.DIVIDER)
            Row() {
              Text('上课教室')
                .fontSize(14)
                .fontColor(ColorConstants.TEXT_PRIMARY)
                .width(80)
              TextInput({ placeholder: '请输入教室', text: this.classroom })
                .fontSize(14)
                .layoutWeight(1)
                .onChange((val: string) => { this.classroom = val; })
            }
            .width('100%')
            .padding({ top: 12, bottom: 12 })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .backgroundColor(ColorConstants.BG_CARD)
          .borderRadius(12)
          .margin({ bottom: 12 })

          // 时间信息
          Column() {
            Row() {
              Text('星期')
                .fontSize(14)
                .fontColor(ColorConstants.TEXT_PRIMARY)
                .width(80)
              Select([{ value: '周一' }, { value: '周二' }, { value: '周三' },
                { value: '周四' }, { value: '周五' }, { value: '周六' }, { value: '周日' }])
                .selected(this.selectedDay - 1)
                .value(this.weekDays[this.selectedDay - 1])
                .layoutWeight(1)
                .onSelect((index: number) => { this.selectedDay = index + 1; })
            }
            .width('100%')
            .padding({ top: 12, bottom: 12 })
            Divider().color(ColorConstants.DIVIDER)
            Row() {
              Text('开始节次')
                .fontSize(14)
                .fontColor(ColorConstants.TEXT_PRIMARY)
                .width(80)
              Slider({ value: this.startSection, min: 1, max: 12, step: 1, style: SliderStyle.OutSet })
                .layoutWeight(1)
                .blockColor(ColorConstants.PRIMARY)
                .selectedColor(ColorConstants.PRIMARY)
                .onChange((value: number) => {
                  this.startSection = Math.round(value);
                  if (this.endSection < this.startSection) this.endSection = this.startSection;
                })
            }
            .width('100%')
            .padding({ top: 12, bottom: 12 })
            Divider().color(ColorConstants.DIVIDER)
            Row() {
              Text('结束节次')
                .fontSize(14)
                .fontColor(ColorConstants.TEXT_PRIMARY)
                .width(80)
              Slider({ value: this.endSection, min: 1, max: 12, step: 1, style: SliderStyle.OutSet })
                .layoutWeight(1)
                .blockColor(ColorConstants.PRIMARY)
                .selectedColor(ColorConstants.PRIMARY)
                .onChange((value: number) => {
                  this.endSection = Math.round(value);
                })
            }
            .width('100%')
            .padding({ top: 12, bottom: 12 })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .backgroundColor(ColorConstants.BG_CARD)
          .borderRadius(12)
          .margin({ bottom: 12 })

          // 周次信息
          Column() {
            Row() {
              Text('起始周')
                .fontSize(14)
                .fontColor(ColorConstants.TEXT_PRIMARY)
                .width(80)
              Slider({ value: this.weekStart, min: 1, max: 20, step: 1, style: SliderStyle.OutSet })
                .layoutWeight(1)
                .blockColor(ColorConstants.PRIMARY)
                .selectedColor(ColorConstants.PRIMARY)
                .onChange((value: number) => {
                  this.weekStart = Math.round(value);
                })
            }
            .width('100%')
            .padding({ top: 12, bottom: 12 })
            Divider().color(ColorConstants.DIVIDER)
            Row() {
              Text('结束周')
                .fontSize(14)
                .fontColor(ColorConstants.TEXT_PRIMARY)
                .width(80)
              Slider({ value: this.weekEnd, min: 1, max: 20, step: 1, style: SliderStyle.OutSet })
                .layoutWeight(1)
                .blockColor(ColorConstants.PRIMARY)
                .selectedColor(ColorConstants.PRIMARY)
                .onChange((value: number) => {
                  this.weekEnd = Math.round(value);
                })
            }
            .width('100%')
            .padding({ top: 12, bottom: 12 })
            Divider().color(ColorConstants.DIVIDER)
            Row() {
              Text('学分')
                .fontSize(14)
                .fontColor(ColorConstants.TEXT_PRIMARY)
                .width(80)
              Slider({ value: this.credit, min: 0.5, max: 6, step: 0.5, style: SliderStyle.OutSet })
                .layoutWeight(1)
                .blockColor(ColorConstants.PRIMARY)
                .selectedColor(ColorConstants.PRIMARY)
                .onChange((value: number) => {
                  this.credit = value;
                })
            }
            .width('100%')
            .padding({ top: 12, bottom: 12 })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .backgroundColor(ColorConstants.BG_CARD)
          .borderRadius(12)
          .margin({ bottom: 12 })

          // 课程颜色
          Column() {
            Text('课程颜色')
              .fontSize(13)
              .fontColor(ColorConstants.TEXT_SECONDARY)
              .margin({ bottom: 12 })
            Row() {
              ForEach(this.colors, (color: string, index: number) => {
                Circle({ width: 32, height: 32 })
                  .fill(color)
                  .stroke(this.colorIndex === index ? '#FFFFFF' : ColorConstants.TRANSPARENT)
                  .strokeWidth(3)
                  .margin({ right: 12 })
                  .onClick(() => {
                    this.colorIndex = index;
                  })
              }, (color: string) => color)
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(ColorConstants.BG_CARD)
          .borderRadius(12)
          .margin({ bottom: 12 })

          // 备注
          Column() {
            Text('备注')
              .fontSize(13)
              .fontColor(ColorConstants.TEXT_SECONDARY)
              .margin({ bottom: 8 })
            TextArea({ placeholder: '请输入备注信息', text: this.remark })
              .fontSize(14)
              .height(80)
              .onChange((value: string) => {
                this.remark = value;
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(ColorConstants.BG_CARD)
          .borderRadius(12)
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }

  private async saveCourse(): Promise<void> {
    if (!this.courseName.trim()) {
      CommonUtil.showToast('请输入课程名称');
      return;
    }

    const course: Course = {
      id: CommonUtil.generateId(),
      name: this.courseName.trim(),
      teacher: this.teacher.trim(),
      classroom: this.classroom.trim(),
      dayOfWeek: this.selectedDay,
      startSection: this.startSection,
      endSection: this.endSection,
      weekStart: this.weekStart,
      weekEnd: this.weekEnd,
      color: this.colors[this.colorIndex],
      credit: this.credit,
      remark: this.remark.trim() || undefined
    };

    this.isSaving = true;
    const success = await this.viewModel.addCourse(course);
    this.isSaving = false;
    if (success) {
      CommonUtil.showToast('添加成功');
      router.back();
    } else {
      CommonUtil.showToast('添加失败');
    }
  }
}
