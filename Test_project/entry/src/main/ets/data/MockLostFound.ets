import { LostFoundItem } from '../model/LostFound';

export class MockLostFound {
  static getItemList(): LostFoundItem[] {
    return [
      {
        id: 'lf001', type: 'lost', title: '丢失黑色钱包',
        description: '今天下午在图书馆二楼自习室丢失一个黑色皮质钱包，内有身份证、校园卡和部分现金。钱包是长方形的，有一个小的logo。如有拾到者请联系，万分感谢！',
        location: '图书馆二楼', time: '2024-01-15 16:30',
        contact: '13812345678', category: '证件',
        status: 'active', publishTime: '2024-01-15 17:00'
      },
      {
        id: 'lf002', type: 'found', title: '拾到一串钥匙',
        description: '在第一食堂门口拾到一串钥匙，大约有5-6把，还有一个蓝色的钥匙扣（小熊造型）。失主请联系确认。',
        location: '第一食堂门口', time: '2024-01-15 12:45',
        contact: '13987654321', category: '钥匙',
        status: 'active', publishTime: '2024-01-15 13:00'
      },
      {
        id: 'lf003', type: 'lost', title: '丢失AirPods Pro耳机',
        description: '昨天晚上在操场跑步时丢失一副AirPods Pro，白色充电盒，盒上有划痕。耳机是去年买的，对我很重要，有看到的同学请联系我，必有重谢！',
        location: '学校操场', time: '2024-01-14 20:00',
        contact: '13666668888', category: '电子产品',
        status: 'active', publishTime: '2024-01-14 21:30'
      },
      {
        id: 'lf004', type: 'found', title: '捡到一本高等数学教材',
        description: '在教1-201教室捡到一本《高等数学》教材，书内有笔记和名字，书的封面有磨损。失主看到消息可以联系我认领。',
        location: '教1-201教室', time: '2024-01-15 10:00',
        contact: '13555556666', category: '书籍',
        status: 'active', publishTime: '2024-01-15 10:30'
      },
      {
        id: 'lf005', type: 'lost', title: '丢失学生卡',
        description: '今天中午在第二食堂丢失校园卡一张，姓名：李四，学号：2022002002。卡套是透明的，上面有个原神的挂件。捡到请联系，谢谢！',
        location: '第二食堂', time: '2024-01-15 12:20',
        contact: '13777779999', category: '证件',
        status: 'active', publishTime: '2024-01-15 13:30'
      },
      {
        id: 'lf006', type: 'found', title: '捡到一部手机',
        description: '在体育馆更衣室捡到一部华为手机，黑色的，屏幕有一道裂痕。手机设了密码，我已经交到体育馆前台了，失主可以去认领。',
        location: '体育馆', time: '2024-01-14 17:30',
        contact: '体育馆前台', category: '电子产品',
        status: 'active', publishTime: '2024-01-14 18:00'
      },
      {
        id: 'lf007', type: 'lost', title: '丢失一把伞',
        description: '昨天下午下雨，把一把深蓝色长柄伞落在教学楼走廊了。伞很大，是自动的，手柄是弯的。对我来说很重要，是朋友送的生日礼物。',
        location: '教3号楼', time: '2024-01-14 16:00',
        contact: '13822223333', category: '其他',
        status: 'active', publishTime: '2024-01-14 17:00'
      },
      {
        id: 'lf008', type: 'found', title: '拾到学生证一个',
        description: '在图书馆一楼大厅座位上拾到一个学生证，是计算机学院的同学。我放在图书馆服务台了，失主可以去拿。',
        location: '图书馆一楼', time: '2024-01-13 21:00',
        contact: '图书馆服务台', category: '证件',
        status: 'completed', publishTime: '2024-01-13 21:30'
      },
      {
        id: 'lf009', type: 'lost', title: '丢失水杯',
        description: '丢失一个膳魔师保温杯，银色的，500ml，杯盖上有提绳。昨天在实验楼做实验的时候忘拿了，回去找已经不见了。',
        location: '实验楼', time: '2024-01-13 15:00',
        contact: '13944445555', category: '其他',
        status: 'active', publishTime: '2024-01-13 16:00'
      },
      {
        id: 'lf010', type: 'found', title: '捡到U盘一个',
        description: '在计算机机房捡到一个黑色U盘，金士顿的，32G。里面有很多重要的学习资料，失主一定很着急。请联系我来认领。',
        location: '实验楼-302机房', time: '2024-01-12 20:30',
        contact: '13611112222', category: '电子产品',
        status: 'active', publishTime: '2024-01-12 21:00'
      }
    ];
  }
}
