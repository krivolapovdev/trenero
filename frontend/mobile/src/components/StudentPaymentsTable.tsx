import dayjs from 'dayjs';
import { memo, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { View } from 'react-native';
import { DataTable, useTheme } from 'react-native-paper';
import type { GetStudentQuery } from '@/src/graphql/__generated__/graphql';

type Props = {
  payments: NonNullable<GetStudentQuery['student']>['payments'];
  itemsPerPage?: number;
  onRowPress: (id: string) => void;
};

export const StudentPaymentsTable = memo(
  ({ payments, itemsPerPage = 5, onRowPress }: Readonly<Props>) => {
    const { t } = useTranslation();
    const theme = useTheme();

    const [page, setPage] = useState(0);
    const [sortAscending, setSortAscending] = useState(true);

    const sortedPayments = useMemo(
      () =>
        [...payments].sort((a, b) => {
          const dateA = dayjs(a.date);
          const dateB = dayjs(b.date);
          return sortAscending ? dateA.diff(dateB) : dateB.diff(dateA);
        }),
      [payments, sortAscending]
    );

    const from = page * itemsPerPage;
    const to = Math.min((page + 1) * itemsPerPage, payments.length);

    if (!sortedPayments.length) {
      return null;
    }

    return (
      <View style={{ borderRadius: 16, backgroundColor: theme.colors.surface }}>
        <DataTable>
          <DataTable.Header>
            <DataTable.Title
              sortDirection={sortAscending ? 'ascending' : 'descending'}
              onPress={() => setSortAscending(prev => !prev)}
              textStyle={{ fontSize: 15 }}
            >
              {t('payments')}
            </DataTable.Title>

            <DataTable.Title
              textStyle={{ fontSize: 15 }}
              numeric={true}
            >
              🎫
            </DataTable.Title>

            <DataTable.Title
              textStyle={{ fontSize: 15 }}
              numeric={true}
            >
              💲
            </DataTable.Title>
          </DataTable.Header>

          {sortedPayments.slice(from, to).map(pay => (
            <DataTable.Row
              key={pay.id}
              onPress={() => onRowPress(pay.id)}
            >
              <DataTable.Cell>
                {dayjs(pay.date).format('DD/MM/YYYY')}
              </DataTable.Cell>

              <DataTable.Cell numeric={true}>
                {pay.lessonsPerPayment}
              </DataTable.Cell>

              <DataTable.Cell numeric={true}>{pay.amount}</DataTable.Cell>
            </DataTable.Row>
          ))}

          <DataTable.Pagination
            page={page}
            numberOfPages={Math.ceil(payments.length / itemsPerPage)}
            onPageChange={setPage}
            numberOfItemsPerPage={itemsPerPage}
          />
        </DataTable>
      </View>
    );
  }
);
