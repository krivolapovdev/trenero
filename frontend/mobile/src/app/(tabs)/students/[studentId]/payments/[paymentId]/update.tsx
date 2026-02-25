import dayjs from 'dayjs';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useEffect } from 'react';
import { useAsyncCallback } from 'react-async-hook';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import * as R from 'remeda';
import type { components } from '@/src/api/generated/openapi';
import { updatePayment } from '@/src/api/services/payment/paymentService';
import {
  PaymentForm,
  type PaymentFormValues
} from '@/src/components/Form/PaymentForm';
import { extractErrorMessage } from '@/src/helpers/apiError';
import { useMetricsStore } from '@/src/stores/metricsStore';
import { useStudentsStore } from '@/src/stores/studentsStore';
import type { StudentDetails } from '@/src/types/student';

type UpdatePaymentRequest = components['schemas']['UpdatePaymentRequest'];

export default function UpdatePaymentScreen() {
  const router = useRouter();
  const { t } = useTranslation();
  const { studentId, paymentId } = useLocalSearchParams<{
    studentId: string;
    paymentId: string;
  }>();

  const removeStudent = useStudentsStore(state => state.removeStudent);
  const adjustMetricTotal = useMetricsStore(state => state.adjustMetricTotal);
  const student = useStudentsStore(
    state => state.allStudents[studentId]
  ) as StudentDetails;
  const payment = student?.studentPayments.find(
    payment => payment.id === paymentId
  );

  const {
    execute: executeUpdatePayment,
    loading: isUpdatingPayment,
    error
  } = useAsyncCallback((body: UpdatePaymentRequest) =>
    updatePayment(paymentId, body)
  );

  const handleSubmit = async (values: PaymentFormValues) => {
    if (!payment || isUpdatingPayment) {
      return;
    }

    const request: UpdatePaymentRequest = {};

    if (values.amount !== payment.amount) {
      request.amount = values.amount;
    }

    if (values.paidUntil !== payment.paidUntil) {
      request.paidUntil = values.paidUntil;
    }

    if (values.date !== payment.date) {
      request.date = values.date;
    }

    if (R.isEmpty(request)) {
      router.back();
      return;
    }

    await executeUpdatePayment(request);

    adjustMetricTotal(dayjs(payment.date), -payment.amount);
    adjustMetricTotal(dayjs(values.date), values.amount);

    removeStudent(studentId);

    router.back();
  };

  useEffect(() => {
    if (error) {
      Alert.alert(t('error'), extractErrorMessage(error));
    }
  }, [error, t]);

  return (
    <PaymentForm
      title={t('editPayment')}
      initialData={{
        payment
      }}
      mutationLoading={isUpdatingPayment}
      onBack={router.back}
      onSubmit={handleSubmit}
    />
  );
}
