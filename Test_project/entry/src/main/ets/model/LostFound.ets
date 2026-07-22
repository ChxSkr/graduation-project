export type ItemType = 'lost' | 'found';

export interface LostFoundItem {
  id: string;
  type: ItemType;
  title: string;
  description: string;
  location: string;
  time: string;
  contact: string;
  images?: string[];
  category: string;
  status: 'active' | 'completed';
  publishTime: string;
}
