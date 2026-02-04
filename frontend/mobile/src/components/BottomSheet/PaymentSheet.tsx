import dayjs from 'dayjs';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useEffect } from 'react';
import { useAsyncCallback } from 'react-async-hook';
import { useTranslation } from 'react-i18next';
import { Alert, View } from 'react-native';
import { Button } from 'react-native-paper';
import { paymentService } from '@/src/api/services/payment/paymentService';
import { CustomBottomSheet } from '@/src/components/BottomSheet/CustomBottomSheet';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { useMetricsStore } from '@/src/stores/metricsStore';
import { useStudentsStore } from '@/src/stores/studentsStore';
import type { StudentDetails } from '@/src/types/student';

type Props = {
  paymentId: string;
  visible: boolean;
  onDismiss: () => void;
};

export const PaymentSheet = ({
  paymentId,
  visible,
  onDismiss
}: Readonly<Props>) => {
  const { t } = useTranslation();
  const theme = useAppTheme();
  const router = useRouter();
  const { studentId } = useLocalSearchParams<{
    studentId: string;
  }>();

  const student = useStudentsStore(
    state => state.allStudents[studentId]
  ) as StudentDetails;
  const removePayment = useStudentsStore(state => state.removePayment);
  const adjustMetricTotal = useMetricsStore(state => state.adjustMetricTotal);

  const {
    execute: deletePayment,
    loading: deletePaymentPending,
    error
  } = useAsyncCallback(async () => {
    await paymentService.delete(paymentId);

    removePayment(studentId, paymentId);

    const payment = student?.studentPayments.find(pay => pay.id === paymentId);
    if (payment) {
      const month = dayjs(payment?.date);
      adjustMetricTotal(month, -payment.amount);
    }

    onDismiss();
  });

  useEffect(() => {
    if (error) {
      Alert.alert(t('error'), error.message);
    }
  }, [error, t]);

  return (
    <CustomBottomSheet
      visible={visible}
      onDismiss={onDismiss}
    >
      <View style={{ gap: 16, padding: 16 }}>
        <Button
          mode='contained-tonal'
          textColor={theme.colors.primary}
          buttonColor={theme.colors.surface}
          onPress={() => {
            router.push(
              `/(tabs)/students/${studentId}/payments/${paymentId}/update`
            );
            onDismiss();
          }}
          disabled={deletePaymentPending}
        >
          {t('edit')}
        </Button>

        <Button
          mode='contained-tonal'
          textColor={theme.colors.error}
          buttonColor={theme.colors.tertiaryContainer}
          onPress={() =>
            void deletePayment()
              .then(() => router.back())
              .catch(err => Alert.alert(t('error'), err.message))
          }
          disabled={deletePaymentPending}
          loading={deletePaymentPending}
        >
          {t('delete')}
        </Button>
      </View>
    </CustomBottomSheet>
  );
};
