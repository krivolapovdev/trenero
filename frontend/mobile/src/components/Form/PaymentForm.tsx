import dayjs from 'dayjs';
import { memo, useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Alert, RefreshControl, ScrollView, StyleSheet } from 'react-native';
import type { components } from '@/src/api/generated/openapi';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { CustomTextInput } from '@/src/components/CustomTextInput';
import { formatDateInput } from '@/src/helpers/formatDateInput';
import { formatPriceInput } from '@/src/helpers/formatPriceInput';
import { parsePastOrTodayDateFromInput } from '@/src/helpers/parsePastOrTodayDateFromInput';
import { useAppTheme } from '@/src/hooks/useAppTheme';

export type PaymentFormValues = {
  amount: number;
  paidLessons: number;
  date: string;
};

type PaymentFormInitialData = {
  payment?: components['schemas']['PaymentResponse'];
};

type Props = {
  title: string;
  queryLoading: boolean;
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
    const [paidLessons, setPaidLessons] = useState('');
    const [date, setDate] = useState(dayjs().format('DD/MM/YYYY'));

    const handleSubmit = () => {
      const parsedLessons = Number(paidLessons);
      if (!parsedLessons || Number.isNaN(parsedLessons)) {
        return Alert.alert(t('error'), t('enterLessonsError'));
      }

      const parsedDate = parsePastOrTodayDateFromInput(date);
      if (!parsedDate) {
        return Alert.alert(t('error'), t('invalidDateError'));
      }

      const values: PaymentFormValues = {
        amount: Number(amount),
        paidLessons: parsedLessons,
        date: parsedDate.format('YYYY-MM-DD')
      };

      onSubmit(values);
    };

    const isLoading = queryLoading || mutationLoading;

    useEffect(() => {
      if (initialData?.payment) {
        setAmount(initialData.payment.amount?.toString() ?? '');
        setPaidLessons(initialData.payment.paidLessons?.toString() ?? '');
        setDate(dayjs(initialData.payment.date).format('DD/MM/YYYY'));
      }
    }, [initialData]);

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
              disabled:
                isLoading || !amount || !paidLessons || date.length !== 10,
              onPress: handleSubmit
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

          <CustomTextInput
            label={`${t('paidLessons')} *`}
            keyboardType='numeric'
            value={paidLessons?.toString() ?? ''}
            onChangeText={text => setPaidLessons(text.replaceAll(/\D/g, ''))}
            disabled={isLoading}
          />

          <CustomTextInput
            label={`${t('date')} *`}
            keyboardType='numeric'
            maxLength={10}
            value={date}
            onChangeText={text => setDate(formatDateInput(text))}
            disabled={isLoading}
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
