import { useDeferredValue, useMemo } from 'react';
import type { StudentOverview, StudentStatus } from '@/src/types/student';

export function useFilteredStudents(
  studentsRecord: Record<string, StudentOverview>,
  searchQuery: string,
  filterGroup: string | null,
  filterStatus: StudentStatus | null
) {
  const deferredQuery = useDeferredValue(searchQuery).trim().toLowerCase();

  return useMemo(() => {
    const allStudents = Object.values(studentsRecord);

    return allStudents.filter(student => {
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
    });
  }, [studentsRecord, deferredQuery, filterGroup, filterStatus]);
}
