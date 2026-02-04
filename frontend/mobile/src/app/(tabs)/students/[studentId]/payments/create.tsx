import dayjs from 'dayjs';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { t } from 'i18next';
import { useEffect } from 'react';
import { useAsyncCallback } from 'react-async-hook';
import { Alert } from 'react-native';
import type { components } from '@/src/api/generated/openapi';
import { paymentService } from '@/src/api/services/payment/paymentService';
import {
  PaymentForm,
  type PaymentFormValues
} from '@/src/components/Form/PaymentForm';
import { useGroupsStore } from '@/src/stores/groupsStore';
import { useMetricsStore } from '@/src/stores/metricsStore';
import { useStudentsStore } from '@/src/stores/studentsStore';

type CreateStudentPaymentRequest =
  components['schemas']['CreateStudentPaymentRequest'];

export default function CreatePaymentScreen() {
  const router = useRouter();
  const { studentId } = useLocalSearchParams<{ studentId: string }>();

  const recentStudents = useStudentsStore(state => state.recentStudents);
  const student = recentStudents.find(student => student.id === studentId);
  const removeStudent = useStudentsStore(state => state.removeStudent);
  const adjustMetricTotal = useMetricsStore(state => state.adjustMetricTotal);
  const allGroups = useGroupsStore(state => state.allGroups);
  const group = allGroups.find(g => g.id === student?.studentGroup?.id);
  const defaultPrice = group?.defaultPrice;

  const {
    execute: createPayment,
    loading: createPaymentLoading,
    error
  } = useAsyncCallback(paymentService.create);

  const handleSubmit = async (values: PaymentFormValues) => {
    if (createPaymentLoading) {
      return;
    }

    const request: CreateStudentPaymentRequest = {
      studentId,
      ...values
    };

    await createPayment(request);

    adjustMetricTotal(dayjs(values.date), values.amount);

    removeStudent(studentId);

    router.back();
  };

  useEffect(() => {
    if (error) {
      Alert.alert(t('error'), error.message);
    }
  }, [error]);

  return (
    <PaymentForm
      title={t('addPayment')}
      onSubmit={handleSubmit}
      onBack={() => router.back()}
      mutationLoading={createPaymentLoading}
      initialData={{
        payment: {
          amount: defaultPrice
        }
      }}
    />
  );
}
