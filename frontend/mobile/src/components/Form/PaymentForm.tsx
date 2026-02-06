import dayjs from 'dayjs';
import { memo, useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Alert, RefreshControl, ScrollView, StyleSheet } from 'react-native';
import type { components } from '@/src/api/generated/openapi';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { CustomTextInput } from '@/src/components/CustomTextInput';
import { DateInput } from '@/src/components/DateInput';
import { formatPriceInput } from '@/src/helpers/formatPriceInput';
import { parsePastOrTodayDateFromInput } from '@/src/helpers/parsePastOrTodayDateFromInput';
import { useAppTheme } from '@/src/hooks/useAppTheme';

export type PaymentFormValues = {
  amount: number;
  paidUntil: string;
  date: string;
};

type PaymentFormInitialData = {
  payment?: Partial<components['schemas']['StudentPaymentResponse']>;
};

type Props = {
  title: string;
  queryLoading?: boolean;
  mutationLoading?: boolean;
  initialData?: PaymentFormInitialData | null;
  onSubmit: (values: PaymentFormValues) => void;
  onBack: () => void;
};

export const PaymentForm = memo(
  ({
    title,
    queryLoading,
    mutationLoading = false,
    initialData,
    onSubmit,
    onBack
  }: Readonly<Props>) => {
    const { t } = useTranslation();
    const theme = useAppTheme();

    const [amount, setAmount] = useState('');
    const [paidUntil, setPaidUntil] = useState(() => {
      if (initialData?.payment?.paidUntil) {
        return dayjs(initialData.payment.paidUntil).format('DD.MM.YYYY');
      }
      return dayjs().add(1, 'month').format('DD.MM.YYYY');
    });
    const [date, setDate] = useState(dayjs().format('DD.MM.YYYY'));

    const handleSubmit = () => {
      const parsedDate = parsePastOrTodayDateFromInput(date);
      if (!parsedDate) {
        return Alert.alert(t('error'), t('invalidDateError'));
      }

      const values: PaymentFormValues = {
        amount: Number(amount),
        paidUntil: dayjs(paidUntil, 'DD.MM.YYYY').format('YYYY-MM-DD'),
        date: parsedDate.format('YYYY-MM-DD')
      };

      onSubmit(values);
    };

    const isLoading = queryLoading || mutationLoading;

    useEffect(() => {
      if (initialData?.payment) {
        setAmount(initialData.payment.amount?.toString() ?? '');
        if (initialData.payment.paidUntil) {
          setPaidUntil(
            dayjs(initialData.payment.paidUntil).format('DD.MM.YYYY')
          );
        }
        setDate(dayjs(initialData.payment.date).format('DD.MM.YYYY'));
      }
    }, [initialData]);

    const isSaveDisabled =
      isLoading || !amount || date.length !== 10 || paidUntil.length !== 10;

    return (
      <>
        <CustomAppbar
          title={title}
          leftActions={[
            { icon: 'arrow-left', onPress: onBack, disabled: mutationLoading }
          ]}
          rightActions={[
            {
              icon: 'content-save',
              onPress: handleSubmit,
              disabled: isSaveDisabled
            }
          ]}
        />

        <ScrollView
          contentContainerStyle={[
            styles.container,
            { backgroundColor: theme.colors.surfaceVariant }
          ]}
          keyboardShouldPersistTaps='handled'
          refreshControl={<RefreshControl refreshing={isLoading} />}
        >
          <CustomTextInput
            label={`${t('amount')} *`}
            keyboardType='numeric'
            value={amount}
            onChangeText={text => setAmount(formatPriceInput(text))}
            disabled={isLoading}
          />

          <DateInput
            label={t('paidUntil')}
            value={paidUntil}
            disabled={isLoading}
            onChange={setPaidUntil}
          />

          <DateInput
            label={t('date')}
            value={date}
            disabled={isLoading}
            onChange={setDate}
          />
        </ScrollView>
      </>
    );
  }
);

const styles = StyleSheet.create({
  container: {
    padding: 24,
    gap: 16,
    flex: 1
  }
});
