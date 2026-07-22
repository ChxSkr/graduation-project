export interface NewsItem {
  id: string;
  title: string;
  summary: string;
  content: string;
  category: string;
  coverImage?: string;
  publishTime: string;
  author: string;
  views: number;
}

export interface NewsCategory {
  id: string;
  name: string;
}
