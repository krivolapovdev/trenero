import { useQueries } from '@tanstack/react-query';
import { api } from '@/src/api';

export function useInitApp() {
  const queries = useQueries({
    queries: [
      api.queryOptions('get', '/api/v1/metrics/payments/monthly'),

      api.queryOptions('get', '/api/v1/groups/overview'),

      api.queryOptions('get', '/api/v1/students/overview')
    ]
  });

  const isLoading = queries.some(q => q.isLoading);

  return {
    isLoading
  };
}
