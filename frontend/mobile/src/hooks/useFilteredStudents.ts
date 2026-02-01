import { useDeferredValue, useMemo } from 'react';
import type { components } from '@/src/api/generated/openapi';
import type { StudentStatus } from '@/src/types/student';

export function useFilteredStudents(
  students: components['schemas']['StudentOverviewResponse'][],
  searchQuery: string,
  filterGroup: string | null,
  filterStatus: StudentStatus | null
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

        if (filterGroup && student.studentGroup?.id !== filterGroup) {
          return false;
        }

        if (filterStatus) {
          if (!student.statuses?.includes(filterStatus)) {
            return false;
          }
        }

        return true;
      }),
    [students, deferredQuery, filterGroup, filterStatus]
  );
}
