export interface Course {
  id: string;
  name: string;
  teacher: string;
  classroom: string;
  dayOfWeek: number;      // 1-7, 1=周一
  startSection: number;   // 1-12
  endSection: number;     // 1-12
  weekStart: number;
  weekEnd: number;
  color: string;
  credit: number;
  remark?: string;
}
