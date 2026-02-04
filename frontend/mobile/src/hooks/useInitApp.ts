import { useAsync } from 'react-async-hook';
import { groupService } from '@/src/api/services/group/groupService';
import { metricService } from '@/src/api/services/metric/metricService';
import { studentService } from '@/src/api/services/student/studentService';
import { useGroupsStore } from '@/src/stores/groupsStore';
import { useMetricsStore } from '@/src/stores/metricsStore';
import { useStudentsStore } from '@/src/stores/studentsStore';

export function useInitApp() {
  const setAllMetrics = useMetricsStore(state => state.setAllMetrics);
  const setAllGroups = useGroupsStore(state => state.setAllGroups);
  const setAllStudents = useStudentsStore(state => state.setAllStudents);

  const { loading, error } = useAsync(async () => {
    const [metrics, groups, students] = await Promise.all([
      metricService.getMonthlyPayments(),
      groupService.getOverview(),
      studentService.getOverview()
    ]);

    setAllMetrics(metrics);
    setAllGroups(groups);
    setAllStudents(students);

    return { metrics, groups, students };
  }, []);

  return {
    loading,
    error
  };
}
