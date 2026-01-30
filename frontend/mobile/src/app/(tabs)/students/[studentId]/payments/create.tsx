import dayjs from 'dayjs';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { t } from 'i18next';
import { Alert } from 'react-native';
import { api } from '@/src/api';
import type { components } from '@/src/api/generated/openapi';
import {
  PaymentForm,
  type PaymentFormValues
} from '@/src/components/Form/PaymentForm';
import { useCustomAsyncCallback } from '@/src/hooks/useCustomAsyncCallback';
import { useMetricsStore } from '@/src/stores/metricsStore';
import { useStudentsStore } from '@/src/stores/studentsStore';
import type { ApiError } from '@/src/types/error';

type CreatePaymentRequest = components['schemas']['CreatePaymentRequest'];

export default function CreatePaymentScreen() {
  const router = useRouter();
  const { studentId } = useLocalSearchParams<{ studentId: string }>();

  const removeStudent = useStudentsStore(state => state.removeStudent);
  const adjustMetricTotal = useMetricsStore(state => state.adjustMetricTotal);

  const { execute: createPayment, loading: createPaymentLoading } =
    useCustomAsyncCallback((request: CreatePaymentRequest) =>
      api.POST('/api/v1/payments', {
        body: request
      })
    );

  const handleSubmit = async (values: PaymentFormValues) => {
    if (createPaymentLoading) {
      return;
    }

    const request: CreatePaymentRequest = {
      studentId,
      ...values
    };

    try {
      await createPayment(request);
      adjustMetricTotal(dayjs(values.date), values.amount);
      removeStudent(studentId);
      router.back();
    } catch (err) {
      const errorData = err as ApiError;
      Alert.alert(t('error'), errorData.detail);
    }
  };

  return (
    <PaymentForm
      title={t('addPayment')}
      onSubmit={handleSubmit}
      onBack={() => router.back()}
      mutationLoading={createPaymentLoading}
    />
  );
}
