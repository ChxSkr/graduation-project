import { CardInfo, ConsumptionRecord } from '../model/CampusCard';

export class MockCardData {
  static getCardInfo(): CardInfo {
    return {
      cardNo: '6222021234567890123',
      balance: 256.80,
      userName: '张三',
      status: 'normal'
    };
  }

  static getRecords(): ConsumptionRecord[] {
    return [
      { id: 'r001', amount: -12.50, type: 'consume', location: '第一食堂', time: '2024-01-15 12:30', description: '午餐' },
      { id: 'r002', amount: -3.50, type: 'consume', location: '便利店', time: '2024-01-15 09:15', description: '饮料' },
      { id: 'r003', amount: 100.00, type: 'recharge', location: '线上充值', time: '2024-01-14 20:00', description: '微信充值' },
      { id: 'r004', amount: -15.00, type: 'consume', location: '第二食堂', time: '2024-01-14 18:20', description: '晚餐' },
      { id: 'r005', amount: -8.50, type: 'consume', location: '第一食堂', time: '2024-01-14 12:15', description: '午餐' },
      { id: 'r006', amount: -20.00, type: 'consume', location: '校园超市', time: '2024-01-13 16:30', description: '日用品' },
      { id: 'r007', amount: -6.00, type: 'consume', location: '打印店', time: '2024-01-13 14:00', description: '打印资料' },
      { id: 'r008', amount: -10.50, type: 'consume', location: '第一食堂', time: '2024-01-13 07:45', description: '早餐' },
      { id: 'r009', amount: 50.00, type: 'recharge', location: '线上充值', time: '2024-01-12 21:30', description: '支付宝充值' },
      { id: 'r010', amount: -18.00, type: 'consume', location: '第三食堂', time: '2024-01-12 12:20', description: '午餐' },
      { id: 'r011', amount: -5.00, type: 'consume', location: '图书馆咖啡', time: '2024-01-12 10:00', description: '咖啡' },
      { id: 'r012', amount: -25.00, type: 'consume', location: '校园水果店', time: '2024-01-11 17:30', description: '水果' },
      { id: 'r013', amount: -13.50, type: 'consume', location: '第二食堂', time: '2024-01-11 12:10', description: '午餐' },
      { id: 'r014', amount: 200.00, type: 'recharge', location: '充值中心', time: '2024-01-10 15:00', description: '现金充值' },
      { id: 'r015', amount: -9.00, type: 'consume', location: '第一食堂', time: '2024-01-10 08:00', description: '早餐' }
    ];
  }
}
