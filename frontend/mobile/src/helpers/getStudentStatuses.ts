import dayjs from 'dayjs';
import * as R from 'remeda';
import type { GetStudentsQuery } from '@/src/graphql/__generated__/graphql';
import type { StudentStatus } from '@/src/types/student';

export function getStudentStatuses(
  student: Pick<
    GetStudentsQuery['students'][number],
    'attendances' | 'payments'
  >
): Set<StudentStatus> {
  const { attendances = [], payments = [] } = student;

  if (attendances.length === 0 && payments.length === 0) {
    return new Set(['noActivity']);
  }

  const statuses = new Set<StudentStatus>();

  const lastAttendance = R.firstBy(attendances, [
    a => dayjs(a.lesson.startDateTime).valueOf(),
    'desc'
  ]);

  if (lastAttendance) {
    statuses.add(lastAttendance.present ? 'present' : 'missing');
  }

  const totalPaid = R.sumBy(payments, p => p.lessonsPerPayment);
  statuses.add(attendances.length <= totalPaid ? 'paid' : 'unpaid');

  return statuses;
}
