import { useDeferredValue, useMemo } from 'react';
import type { GetStudentsQuery } from '@/src/graphql/__generated__/graphql';
import { getStudentStatuses } from '@/src/helpers/getStudentStatuses';
import type { StudentStatus } from '@/src/types/student';

export function useFilteredStudents(
  students: GetStudentsQuery['students'],
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

        if (filterGroup && student.group?.id !== filterGroup) {
          return false;
        }

        if (filterStatus) {
          const statuses = getStudentStatuses(student);

          if (!statuses.has(filterStatus)) {
            return false;
          }
        }

        return true;
      }),
    [students, deferredQuery, filterGroup, filterStatus]
  );
}
