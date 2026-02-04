import { api } from '@/src/api';
import type { paths } from '@/src/api/generated/openapi';

type MonthlyMetricsResponse =
  paths['/api/v1/metrics/payments/monthly']['get']['responses'][200]['content']['*/*'];

export const metricService = {
  async getMonthlyPayments() {
    const { data } = await api.get<MonthlyMetricsResponse>(
      '/api/v1/metrics/payments/monthly'
    );

    return data;
  }
};
