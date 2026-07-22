export interface CardInfo {
  cardNo: string;
  balance: number;
  userName: string;
  status: 'normal' | 'frozen' | 'lost';
}

export interface ConsumptionRecord {
  id: string;
  amount: number;
  type: 'recharge' | 'consume';
  location: string;
  time: string;
  description?: string;
}
