import dayjs from 'dayjs';
import { memo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { View } from 'react-native';
import { DataTable, Text, useTheme } from 'react-native-paper';
import type { components } from '@/src/api/generated/openapi';

const formatShort = (date?: string) =>
  date ? dayjs(date).format('DD.MM.YY') : '';

type Props = {
  payments: components['schemas']['StudentPaymentResponse'][];
  itemsPerPage?: number;
  onRowPress: (id: string) => void;
};

export const StudentPaymentsTable = memo(
  ({ payments, itemsPerPage = 5, onRowPress }: Readonly<Props>) => {
    const { t } = useTranslation();
    const theme = useTheme();

    const [page, setPage] = useState(0);

    const from = page * itemsPerPage;
    const to = Math.min((page + 1) * itemsPerPage, payments.length);

    if (!payments.length) {
      return null;
    }

    return (
      <View style={{ borderRadius: 16, backgroundColor: theme.colors.surface }}>
        <DataTable>
          {payments.slice(from, to).map(pay => (
            <DataTable.Row
              key={pay.id}
              onPress={() => onRowPress(pay.id)}
            >
              <DataTable.Cell>
                {pay.paidFrom
                  ? `${formatShort(pay.paidFrom)} - ${formatShort(pay.paidUntil)}`
                  : `${t('paidUntil')} ${formatShort(pay.paidUntil)}`}
              </DataTable.Cell>

              <DataTable.Cell numeric={true}>
                <Text style={{ color: 'green' }}>+{pay.amount}</Text>
              </DataTable.Cell>
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
