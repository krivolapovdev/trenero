export type StudentStatus =
    | 'no_activity'
    | 'present'
    | 'missing'
    | 'paid'
    | 'unpaid';

export const STUDENT_STATUS_LABEL: Record<StudentStatus, string> = {
  no_activity: 'No activity',
  present: 'Present',
  missing: 'Missing',
  paid: 'Paid',
  unpaid: 'Unpaid'
};
