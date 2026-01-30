import dayjs from 'dayjs';
import { create } from 'zustand';
import type { components } from '@/src/api/generated/openapi';

type MonthlyMetric = components['schemas']['MonthlyPaymentMetricResponse'];

type MonthlyMetricsStore = {
  allMetrics: MonthlyMetric[];
  setAllMetrics: (metrics: MonthlyMetric[]) => void;
  adjustMetricTotal: (month: dayjs.Dayjs, delta: number) => void;
  getMetricsByMonth: (month: dayjs.Dayjs) => MonthlyMetric[];
};

export const useMetricsStore = create<MonthlyMetricsStore>((set, get) => ({
  allMetrics: [],

  setAllMetrics: metrics => set({ allMetrics: metrics }),

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
