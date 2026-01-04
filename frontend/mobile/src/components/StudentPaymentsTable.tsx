import dayjs from 'dayjs';
import { memo, useMemo, useState } from 'react';
import { View } from 'react-native';
import { DataTable, useTheme } from 'react-native-paper';

type Payment = {
  id: string;
  amount: string;
  createdAt: string;
};

type Props = {
  payments: Payment[];
  itemsPerPage?: number;
};

const formatDate = (date: string) => dayjs(date).format('DD/MM/YYYY HH:mm');

export const StudentPaymentsTable = memo(
  ({ payments, itemsPerPage = 5 }: Readonly<Props>) => {
    const theme = useTheme();

    const [page, setPage] = useState(0);
    const [sortAscending, setSortAscending] = useState(true);

    const sortedPayments = useMemo(() => {
      return [...payments].sort((a, b) => {
        const dateA = new Date(a.createdAt).getTime();
        const dateB = new Date(b.createdAt).getTime();
        return sortAscending ? dateA - dateB : dateB - dateA;
      });
    }, [payments, sortAscending]);

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
              Payments
            </DataTable.Title>
            <DataTable.Title
              textStyle={{ fontSize: 15 }}
              numeric
            >
              Amount
            </DataTable.Title>
          </DataTable.Header>

          {sortedPayments.slice(from, to).map(pay => (
            <DataTable.Row key={pay.id}>
              <DataTable.Cell>{formatDate(pay.createdAt)}</DataTable.Cell>
              <DataTable.Cell numeric>{pay.amount}</DataTable.Cell>
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
