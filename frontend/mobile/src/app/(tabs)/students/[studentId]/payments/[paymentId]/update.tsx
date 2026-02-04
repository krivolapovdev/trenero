import dayjs from 'dayjs';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useEffect } from 'react';
import { useAsyncCallback } from 'react-async-hook';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import * as R from 'remeda';
import type { components } from '@/src/api/generated/openapi';
import { paymentService } from '@/src/api/services/payment/paymentService';
import {
  PaymentForm,
  type PaymentFormValues
} from '@/src/components/Form/PaymentForm';
import { useMetricsStore } from '@/src/stores/metricsStore';
import { useStudentsStore } from '@/src/stores/studentsStore';

type UpdatePaymentRequest = components['schemas']['UpdatePaymentRequest'];

export default function UpdatePaymentScreen() {
  const router = useRouter();
  const { t } = useTranslation();
  const { studentId, paymentId } = useLocalSearchParams<{
    studentId: string;
    paymentId: string;
  }>();

  const recentStudents = useStudentsStore(state => state.recentStudents);
  const removeStudent = useStudentsStore(state => state.removeStudent);
  const adjustMetricTotal = useMetricsStore(state => state.adjustMetricTotal);
  const student = recentStudents.find(student => student.id === studentId);
  const payment = student?.studentPayments.find(
    payment => payment.id === paymentId
  );

  const {
    execute: updatePayment,
    loading: updatePaymentLoading,
    error
  } = useAsyncCallback((body: UpdatePaymentRequest) =>
    paymentService.update(paymentId, body)
  );

  const handleSubmit = async (values: PaymentFormValues) => {
    if (!payment || updatePaymentLoading) {
      return;
    }

    const request: UpdatePaymentRequest = {};

    if (values.amount !== payment.amount) {
      request.amount = values.amount;
    }

    if (values.paidLessons !== payment.paidLessons) {
      request.paidLessons = values.paidLessons;
    }

    if (values.date !== payment.date) {
      request.date = values.date;
    }

    if (R.isEmpty(request)) {
      router.back();
      return;
    }

    await updatePayment(request);

    adjustMetricTotal(dayjs(payment.date), -payment.amount);
    adjustMetricTotal(dayjs(values.date), values.amount);

    removeStudent(studentId);

    router.back();
  };

  useEffect(() => {
    if (error) {
      Alert.alert(t('error'), error.message);
    }
  }, [error, t]);

  return (
    <PaymentForm
      title={t('editPayment')}
      initialData={{
        payment
      }}
      mutationLoading={updatePaymentLoading}
      onBack={router.back}
      onSubmit={handleSubmit}
    />
  );
}
