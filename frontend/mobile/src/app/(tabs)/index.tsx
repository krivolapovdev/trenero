import dayjs from 'dayjs';
import { useMemo, useState } from 'react';
import { useAsyncCallback } from 'react-async-hook';
import { useTranslation } from 'react-i18next';
import { RefreshControl, ScrollView, View } from 'react-native';
import { Text } from 'react-native-paper';
import { metricService } from '@/src/api/services/metric/metricService';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { LoadingSpinner } from '@/src/components/LoadingSpinner';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import { RoundedBarChart } from '@/src/components/RoundedBarChart';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { useInitApp } from '@/src/hooks/useInitApp';
import { useMetricsStore } from '@/src/stores/metricsStore';

export default function MetricsScreen() {
  const { t } = useTranslation();
  const theme = useAppTheme();
  const [selectedBar, setSelectedBar] = useState(dayjs());
  const { loading: isInitLoading } = useInitApp();
  const metrics = useMetricsStore(state => state.allMetrics);
  const setAllMetrics = useMetricsStore(state => state.setAllMetrics);

  const { loading, execute, error } = useAsyncCallback(async () => {
    const data = await metricService.getMonthlyPayments();
    setAllMetrics(data);
    return data;
  });

  const monthlyData = useMemo(
    () =>
      metrics.map(m => ({
        date: dayjs(m.date),
        value: m.total
      })),
    [metrics]
  );

  if (isInitLoading) {
    return <LoadingSpinner />;
  }

  return (
    <>
      <CustomAppbar
        title={t('metrics')}
        mode='center-aligned'
      />

      <ScrollView
        contentContainerStyle={{ padding: 16, gap: 16 }}
        showsVerticalScrollIndicator={false}
        style={{
          flex: 1,
          backgroundColor: theme.colors.surfaceVariant
        }}
        refreshControl={
          <RefreshControl
            refreshing={loading}
            onRefresh={execute}
          />
        }
      >
        <OptionalErrorMessage error={error?.message} />

        <View
          style={{
            flex: 1,
            justifyContent: 'space-between',
            flexDirection: 'row',
            backgroundColor: theme.colors.surface,
            padding: 16,
            borderRadius: 16
          }}
        >
          <Text variant='bodyLarge'>{selectedBar.format('MM/YYYY')}</Text>

          <Text variant='bodyLarge'>
            +
            {monthlyData.find(m => m.date.isSame(selectedBar, 'month'))
              ?.value || 0}
          </Text>
        </View>

        <View
          style={{
            justifyContent: 'center',
            alignItems: 'center',
            backgroundColor: theme.colors.surface,
            padding: 16,
            borderRadius: 16
          }}
        >
          <RoundedBarChart
            data={monthlyData}
            selectedBar={selectedBar}
            setSelectedBar={setSelectedBar}
          />
        </View>
      </ScrollView>
    </>
  );
}
