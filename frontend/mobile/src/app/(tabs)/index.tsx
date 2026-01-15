import { useQuery } from '@apollo/client/react';
import dayjs from 'dayjs';
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { RefreshControl, ScrollView, View } from 'react-native';
import { Text } from 'react-native-paper';
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

  const monthlyData = useMemo(
    () =>
      Array.from({ length: 6 })
        .map((_, i) => dayjs().subtract(i, 'month'))
        .map(month => ({
          date: month,
          value:
            data?.students
              .flatMap(student => student.payments)
              .filter(p => dayjs(p.date).isSame(month, 'month'))
              .reduce((sum, p) => sum + Number(p.amount), 0) || 0
        }))
        .reverse(),
    [data]
  );

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
