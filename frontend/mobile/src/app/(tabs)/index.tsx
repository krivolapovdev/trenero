import { useQuery } from '@apollo/client/react';
import dayjs from 'dayjs';
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { RefreshControl, ScrollView, View } from 'react-native';
import { Text } from 'react-native-paper';
import * as R from 'remeda';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import { RoundedBarChart } from '@/src/components/RoundedBarChart';
import { GET_STUDENTS } from '@/src/graphql/queries';
import { useAppTheme } from '@/src/hooks/useAppTheme';

export default function StatisticsScreen() {
  const theme = useAppTheme();
  const { t } = useTranslation();
  const [selectedBar, setSelectedBar] = useState(dayjs());

  const { loading, data, error, refetch } = useQuery(GET_STUDENTS, {
    fetchPolicy: 'cache-first'
  });

  const monthlyData = useMemo(() => {
    const paymentsByMonth = R.pipe(
      data?.students ?? [],
      R.flatMap(s => s.payments),
      R.groupBy(p => dayjs(p.date).format('YYYY-MM')),
      R.mapValues(payments => R.sumBy(payments, p => Number(p.amount)))
    );

    return R.range(0, 6).map(i => {
      const month = dayjs().subtract(5 - i, 'month');
      return {
        date: month,
        value: paymentsByMonth[month.format('YYYY-MM')] ?? 0
      };
    });
  }, [data]);

  return (
    <>
      <CustomAppbar
        title={t('statistics')}
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
            onRefresh={refetch}
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
