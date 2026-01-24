import dayjs from 'dayjs';
import * as R from 'remeda';
import type { components } from '@/src/api/generated/openapi';
import type { StudentStatus } from '@/src/types/student';

export function getStudentStatuses(
  visits: components['schemas']['VisitResponse'][] = [],
  payments: components['schemas']['PaymentResponse'][] = [],
  lessons: components['schemas']['LessonResponse'][] = []
): Set<StudentStatus> {
  if (visits.length === 0 && payments.length === 0) {
    return new Set(['noActivity']);
  }

  const statuses = new Set<StudentStatus>();

  const lastVisit = R.firstBy(visits, [
    visit =>
      dayjs(
        lessons.find(lesson => lesson.id === visit.lessonId)?.startDateTime
      ).valueOf(),
    'desc'
  ]);

  if (lastVisit) {
    statuses.add(lastVisit.present ? 'present' : 'missing');
  }

  const totalPaid = R.sumBy(payments, p => p.paidLessons);

  statuses.add(visits.length <= totalPaid ? 'paid' : 'unpaid');

  return statuses;
}
