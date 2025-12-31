export const STATUS_LIST = [
  'No activity',
  'Present',
  'Missing',
  'Paid',
  'Unpaid'
] as const;

export type Status = (typeof STATUS_LIST)[number];
