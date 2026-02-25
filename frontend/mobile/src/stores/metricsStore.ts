import dayjs from 'dayjs';
import { create } from 'zustand';
import type { components } from '@/src/api/generated/openapi';
import { getMonthlyPayments } from '@/src/api/services/metric/metricService';
import { extractErrorMessage } from '@/src/helpers/apiError';

type MonthlyMetric = components['schemas']['MonthlyPaymentMetricResponse'];

type MonthlyMetricsStore = {
  allMetrics: MonthlyMetric[];
  isRefreshing: boolean;
  error: string | null;

  setAllMetrics: (metrics: MonthlyMetric[]) => void;
  refreshMetrics: () => Promise<void>;
  adjustMetricTotal: (month: dayjs.Dayjs, delta: number) => void;
  getMetricsByMonth: (month: dayjs.Dayjs) => MonthlyMetric[];
};

export const useMetricsStore = create<MonthlyMetricsStore>((set, get) => ({
  allMetrics: [],
  isRefreshing: false,
  error: null,

  setAllMetrics: metrics => set({ allMetrics: metrics }),

  refreshMetrics: async () => {
    set({ isRefreshing: true, error: null });
    try {
      const data = await getMonthlyPayments();
      get().setAllMetrics(data);
    } catch (e: unknown) {
      set({ error: extractErrorMessage(e) });
    } finally {
      set({ isRefreshing: false });
    }
  },

  adjustMetricTotal: (month, delta) =>
    set(state => {
      const exists = state.allMetrics.some(m =>
        dayjs(m.date).isSame(month, 'month')
      );

      if (!exists) {
        return state;
      }

      return {
        allMetrics: state.allMetrics.map(m =>
          dayjs(m.date).isSame(month, 'month')
            ? { ...m, total: (m.total || 0) + delta }
            : m
        )
      };
    }),

  getMetricsByMonth: month =>
    get().allMetrics.filter(m => dayjs(m.date).isSame(month, 'month'))
}));
