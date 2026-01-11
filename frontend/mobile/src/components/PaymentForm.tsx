import dayjs from 'dayjs';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Alert, ScrollView, StyleSheet } from 'react-native';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { CustomTextInput } from '@/src/components/CustomTextInput';
import type { GetPaymentQuery } from '@/src/graphql/__generated__/graphql';
import { formatDateInput } from '@/src/helpers/formatDateInput';
import { formatPriceInput } from '@/src/helpers/formatPriceInput';
import { parsePastOrTodayDateFromInput } from '@/src/helpers/parsePastOrTodayDateFromInput';
import { useAppTheme } from '@/src/hooks/useAppTheme';

export type PaymentFormValues = {
  amount: string;
  lessonsPerPayment: number;
  date: string;
};

type Props = {
  title: string;
  initialData?: Partial<GetPaymentQuery['payment']> | null;
  onSubmit: (values: PaymentFormValues) => void;
  onBack: () => void;
  loading: boolean;
};

export const PaymentForm = ({
  title,
  initialData,
  onSubmit,
  onBack,
  loading
}: Readonly<Props>) => {
  const { t } = useTranslation();
  const theme = useAppTheme();

  const [amount, setAmount] = useState(initialData?.amount ?? '');
  const [lessonsPerPayment, setLessonsPerPayment] = useState<number | null>(
    initialData?.lessonsPerPayment ?? null
  );
  const [date, setDate] = useState(
    initialData?.date ?? dayjs().format('DD/MM/YYYY')
  );

  const handleSubmit = () => {
    if (!lessonsPerPayment) {
      return Alert.alert(t('error'), t('enterLessonsError'));
    }

    const parsedDate = parsePastOrTodayDateFromInput(date);

    if (!parsedDate) {
      return Alert.alert(t('error'), t('invalidDateError'));
    }

    onSubmit({
      amount,
      lessonsPerPayment,
      date: parsedDate.format('YYYY-MM-DD')
    });
  };

  return (
    <>
      <CustomAppbar
        title={title}
        leftActions={[
          { icon: 'arrow-left', onPress: onBack, disabled: loading }
        ]}
        rightActions={[
          {
            icon: 'content-save',
            disabled:
              loading || !amount || !lessonsPerPayment || date.length !== 10,
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
      >
        <CustomTextInput
          label={t('amount')}
          keyboardType='numeric'
          value={amount}
          onChangeText={text => setAmount(formatPriceInput(text))}
          disabled={loading}
        />

        <CustomTextInput
          label={t('lessonsPerPayment')}
          keyboardType='numeric'
          value={lessonsPerPayment?.toString() ?? ''}
          onChangeText={text =>
            setLessonsPerPayment(
              Number.isNaN(Number(text)) ? null : Number(text)
            )
          }
          disabled={loading}
        />

        <CustomTextInput
          label={t('date')}
          keyboardType='numeric'
          maxLength={10}
          value={date}
          onChangeText={text => setDate(formatDateInput(text))}
          disabled={loading}
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
