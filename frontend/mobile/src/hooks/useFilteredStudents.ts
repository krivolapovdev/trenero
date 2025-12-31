import { useDeferredValue, useMemo } from 'react';
import type { GetStudentsQuery } from '@/src/graphql/__generated__/graphql';
import type { Status } from '@/src/types/student';

export const statusChecks: Record<
  Status,
  (student: GetStudentsQuery['students'][number]) => boolean
> = {
  'No activity': student => !student.lastAttendance,
  Present: student => !!student.lastAttendance?.present,
  Missing: student =>
    !!student.lastAttendance && !student.lastAttendance.present,
  Paid: () => true,
  Unpaid: () => true
};

export function useFilteredStudents(
  students: GetStudentsQuery['students'],
  searchQuery: string,
  filterGroup: string | null,
  filterStatus: Status | null
) {
  const deferredQuery = useDeferredValue(searchQuery).trim().toLowerCase();
  const allStudents = students ?? [];

  return useMemo(
    () =>
      allStudents.filter(student => {
        if (
          deferredQuery &&
          !student.fullName.toLowerCase().includes(deferredQuery)
        ) {
          return false;
        }

        if (filterGroup && student.group?.name !== filterGroup) {
          return false;
        }

        if (filterStatus && !statusChecks[filterStatus](student)) {
          return false;
        }

        return true;
      }),
    [allStudents, deferredQuery, filterGroup, filterStatus]
  );
}
