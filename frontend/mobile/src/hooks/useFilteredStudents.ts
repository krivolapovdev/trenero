import { useDeferredValue, useMemo } from 'react';
import type { components } from '@/src/api/generated/openapi';
import type { StudentStatus } from '@/src/types/student';

export function useFilteredStudents(
  students: components['schemas']['StudentResponse'][],
  searchQuery: string,
  filterGroup: string | null,
  _filterStatus: StudentStatus | null
) {
  const deferredQuery = useDeferredValue(searchQuery).trim().toLowerCase();

  return useMemo(
    () =>
      students.filter(student => {
        if (
          deferredQuery &&
          !student.fullName.toLowerCase().includes(deferredQuery)
        ) {
          return false;
        }

        if (filterGroup && student.groupId !== filterGroup) {
          return false;
        }

        // if (filterStatus) {
        //   const statuses = getStudentStatuses(student.visits, student.payments);
        //
        //   if (!statuses.has(filterStatus)) {
        //     return false;
        //   }
        // }

        return true;
      }),
    [students, deferredQuery, filterGroup]
  );
}
