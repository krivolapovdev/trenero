import { useQuery } from '@apollo/client/react';
import dayjs from 'dayjs';
import { useMemo, useState } from 'react';
import { RefreshControl, ScrollView, View } from 'react-native';
import { Text } from 'react-native-paper';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import { RoundedBarChart } from '@/src/components/RoundedBarChart';
import { graphql } from '@/src/graphql/__generated__';
import { useAppTheme } from '@/src/hooks/useAppTheme';

const GET_PAYMENTS = graphql(`
    query GetPayments {
        payments {
            ...PaymentFields
        }
    }
`);

export default function StatisticsScreen() {
  const theme = useAppTheme();
  const [selectedBar, setSelectedBar] = useState(dayjs());

  const { loading, data, error, refetch } = useQuery(GET_PAYMENTS, {
    fetchPolicy: 'cache-first'
  });

  const monthlyData = useMemo(
    () =>
      Array.from({ length: 6 })
        .map((_, i) => dayjs().subtract(i, 'month'))
        .map(month => ({
          date: month,
          value:
            data?.payments
              .filter(p => dayjs(p.createdAt).isSame(month, 'month'))
              .reduce((sum, p) => sum + Number(p.amount), 0) || 0
        }))
        .reverse(),
    [data]
  );

  return (
    <>
      <CustomAppbar title={'Statistics'} />

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
          <Text
            variant={'bodyLarge'}
            style={{ color: theme.colors.primary }}
          >
            {selectedBar.format('MM/YYYY')}
          </Text>

          <Text variant={'bodyLarge'}>
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
