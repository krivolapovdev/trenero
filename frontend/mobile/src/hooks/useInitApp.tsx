import { useEffect } from 'react';
import { useAsync } from 'react-async-hook';
import { api } from '@/src/api';
import { useGroupsStore } from '@/src/stores/groupsStore';
import { useMetricsStore } from '@/src/stores/metricsStore';
import { useStudentsStore } from '@/src/stores/studentsStore';

export function useInitApp() {
  const setAllMetrics = useMetricsStore(state => state.setAllMetrics);
  const setAllGroups = useGroupsStore(state => state.setAllGroups);
  const setAllStudents = useStudentsStore(state => state.setAllStudents);

  const { result, loading } = useAsync(async () => {
    const [metrics, groups, students] = await Promise.all([
      api.GET('/api/v1/metrics/payments/monthly'),
      api.GET('/api/v1/groups/overview'),
      api.GET('/api/v1/students/overview')
    ]);
    return { metrics, groups, students };
  }, []);

  useEffect(() => {
    if (result?.metrics?.data) {
      setAllMetrics(result.metrics.data);
    }
  }, [setAllMetrics, result?.metrics.data]);

  useEffect(() => {
    if (result?.students?.data) {
      setAllStudents(result.students.data);
    }
  }, [result?.students.data, setAllStudents]);

  useEffect(() => {
    if (result?.groups?.data) {
      setAllGroups(result.groups.data);
    }
  }, [result?.groups.data, setAllGroups]);

  return {
    loading
  };
}
