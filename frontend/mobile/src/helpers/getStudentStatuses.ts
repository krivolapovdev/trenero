import dayjs from 'dayjs';
import type {GetStudentsQuery} from '@/src/graphql/__generated__/graphql';
import type {StudentStatus} from '@/src/types/student';

export function getStudentStatuses(
    student: Pick<
        GetStudentsQuery['students'][number],
        'attendances' | 'payments'
    >
): Set<StudentStatus> {
  const {attendances = [], payments = []} = student;

  if (attendances.length === 0 && payments.length === 0) {
    return new Set(['no_activity']);
  }

  const statuses = new Set<StudentStatus>();

  const lastAttendance =
      attendances.length > 0
          ? attendances.reduce((latest, current) =>
              dayjs(current.lesson.startDateTime).isAfter(
                  latest.lesson.startDateTime
              )
                  ? current
                  : latest
          )
          : null;

  if (lastAttendance) {
    statuses.add(lastAttendance.present ? 'present' : 'missing');
  }

  const totalPaid = payments.reduce((sum, p) => sum + p.lessonsPerPayment, 0);
  statuses.add(attendances.length <= totalPaid ? 'paid' : 'unpaid');

  return statuses;
}
