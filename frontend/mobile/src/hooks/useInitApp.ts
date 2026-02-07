import { useEffect } from 'react';
import { useAuthStore } from '@/src/stores/authStore';
import { useGroupsStore } from '@/src/stores/groupsStore';
import { useMetricsStore } from '@/src/stores/metricsStore';
import { useStudentsStore } from '@/src/stores/studentsStore';

export function useInitApp() {
  const user = useAuthStore(state => state.user);
  const refreshGroups = useGroupsStore(state => state.refreshGroups);
  const refreshStudents = useStudentsStore(state => state.refreshStudents);
  const refreshMetrics = useMetricsStore(state => state.refreshMetrics);

  useEffect(() => {
    if (user) {
      void Promise.all([refreshGroups(), refreshStudents(), refreshMetrics()]);
    }
  }, [refreshGroups, refreshStudents, refreshMetrics, user]);
}
