import dayjs from 'dayjs';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Alert, RefreshControl, ScrollView, StyleSheet } from 'react-native';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { CustomTextInput } from '@/src/components/CustomTextInput';
import type { GetPaymentQuery } from '@/src/graphql/__generated__/graphql';
import { formatDateInput } from '@/src/helpers/formatDateInput';
import { formatPriceInput } from '@/src/helpers/formatPriceInput';
import { parsePastOrTodayDateFromInput } from '@/src/helpers/parsePastOrTodayDateFromInput';
import { useAppTheme } from '@/src/hooks/useAppTheme';

export type PaymentFormValues = {
  amount: number;
  lessonsPerPayment: number;
  date: string;
};

type Props = {
  title: string;
  queryLoading: boolean;
  mutationLoading?: boolean;
  initialData?: Partial<GetPaymentQuery['payment']> | null;
  onSubmit: (values: PaymentFormValues) => void;
  onBack: () => void;
};

export const PaymentForm = ({
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
  const [lessonsPerPayment, setLessonsPerPayment] = useState('');
  const [date, setDate] = useState(dayjs().format('DD/MM/YYYY'));

  const handleSubmit = () => {
    const parsedLessons = Number(lessonsPerPayment);
    if (!parsedLessons || Number.isNaN(parsedLessons)) {
      return Alert.alert(t('error'), t('enterLessonsError'));
    }

    const parsedDate = parsePastOrTodayDateFromInput(date);
    if (!parsedDate) {
      return Alert.alert(t('error'), t('invalidDateError'));
    }

    const values: PaymentFormValues = {
      amount: Number(amount),
      lessonsPerPayment: parsedLessons,
      date: parsedDate.format('YYYY-MM-DD')
    };

    onSubmit(values);
  };

  const isLoading = queryLoading || mutationLoading;

  useEffect(() => {
    if (initialData) {
      setAmount(initialData.amount?.toString() ?? '');
      setLessonsPerPayment(initialData.lessonsPerPayment?.toString() ?? '');
      if (initialData.date) {
        setDate(dayjs(initialData.date).format('DD/MM/YYYY'));
      }
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
              isLoading || !amount || !lessonsPerPayment || date.length !== 10,
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
          label={`${t('lessonsPerPayment')} *`}
          keyboardType='numeric'
          value={lessonsPerPayment?.toString() ?? ''}
          onChangeText={text =>
            setLessonsPerPayment(text.replaceAll(/\D/g, ''))
          }
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
};

const styles = StyleSheet.create({
  container: {
    padding: 24,
    gap: 16,
    flex: 1
  }
});
