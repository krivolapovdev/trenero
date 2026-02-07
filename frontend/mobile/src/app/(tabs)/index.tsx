import dayjs from 'dayjs';
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { RefreshControl, ScrollView, View } from 'react-native';
import { Text } from 'react-native-paper';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import { RoundedBarChart } from '@/src/components/RoundedBarChart';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { useMetricsStore } from '@/src/stores/metricsStore';

const getAmountColor = (val: number) => {
  if (val === 0) {
    return 'black';
  }

  return val > 0 ? 'green' : 'red';
};

export default function DashboardScreen() {
  const { t } = useTranslation();
  const theme = useAppTheme();
  const [selectedBar, setSelectedBar] = useState(dayjs());

  const allMetrics = useMetricsStore(state => state.allMetrics);
  const isRefreshing = useMetricsStore(state => state.isRefreshing);
  const error = useMetricsStore(state => state.error);
  const refreshMetrics = useMetricsStore(state => state.refreshMetrics);

  const monthlyData = useMemo(
    () =>
      allMetrics.map(m => ({
        date: dayjs(m.date),
        value: m.total
      })),
    [allMetrics]
  );

  const currentAmount =
    monthlyData.find(m => m.date.isSame(selectedBar, 'month'))?.value ?? 0;

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
            refreshing={isRefreshing}
            onRefresh={refreshMetrics}
          />
        }
      >
        <OptionalErrorMessage error={error} />

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

          <Text
            variant='bodyLarge'
            style={{
              color: getAmountColor(currentAmount)
            }}
          >
            {currentAmount >= 0 ? '+' : '-'}
            {currentAmount}
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
