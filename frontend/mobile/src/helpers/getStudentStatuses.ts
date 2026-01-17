import dayjs from 'dayjs';
import * as R from 'remeda';
import type { GetStudentsQuery } from '@/src/graphql/__generated__/graphql';
import type { StudentStatus } from '@/src/types/student';

export function getStudentStatuses(
  visits: GetStudentsQuery['students'][number]['visits'] = [],
  payments: GetStudentsQuery['students'][number]['payments'] = []
): Set<StudentStatus> {
  if (visits.length === 0 && payments.length === 0) {
    return new Set(['noActivity']);
  }

  const statuses = new Set<StudentStatus>();

  const lastVisit = R.firstBy(visits, [
    a => dayjs(a.lesson.startDateTime).valueOf(),
    'desc'
  ]);

  if (lastVisit) {
    statuses.add(lastVisit.present ? 'present' : 'missing');
  }

  const totalPaid = R.sumBy(payments, p => p.lessonsPerPayment);

  statuses.add(visits.length <= totalPaid ? 'paid' : 'unpaid');

  return statuses;
}
