import dayjs from 'dayjs';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { t } from 'i18next';
import { useEffect, useMemo } from 'react';
import { useAsyncCallback } from 'react-async-hook';
import { Alert } from 'react-native';
import type { components } from '@/src/api/generated/openapi';
import { paymentService } from '@/src/api/services/payment/paymentService';
import {
  PaymentForm,
  type PaymentFormValues
} from '@/src/components/Form/PaymentForm';
import { extractErrorMessage } from '@/src/helpers/apiError';
import { useGroupsStore } from '@/src/stores/groupsStore';
import { useMetricsStore } from '@/src/stores/metricsStore';
import { useStudentsStore } from '@/src/stores/studentsStore';
import type { StudentDetails } from '@/src/types/student';

type CreateStudentPaymentRequest =
  components['schemas']['CreateStudentPaymentRequest'];

export default function CreatePaymentScreen() {
  const router = useRouter();
  const { studentId } = useLocalSearchParams<{ studentId: string }>();

  const student = useStudentsStore(
    state => state.allStudents[studentId]
  ) as StudentDetails;
  const removeStudent = useStudentsStore(state => state.removeStudent);
  const adjustMetricTotal = useMetricsStore(state => state.adjustMetricTotal);
  const group = useGroupsStore(state =>
    student?.groupsHistory.length > 0
      ? state.allGroups[student?.groupsHistory[0].group.id]
      : undefined
  );

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

  const defaultPaidUntil = useMemo(() => {
    const payments = student?.studentPayments;

    if (!payments || payments.length === 0) {
      return dayjs().add(1, 'month').format('YYYY-MM-DD');
    }

    const lastPaidUntilDate = payments.reduce(
      (max, payment) =>
        dayjs(payment.paidUntil).isAfter(dayjs(max)) ? payment.paidUntil : max,
      payments[0].paidUntil
    );

    return dayjs(lastPaidUntilDate).add(1, 'month').format('YYYY-MM-DD');
  }, [student?.studentPayments]);

  useEffect(() => {
    if (error) {
      Alert.alert(t('error'), extractErrorMessage(error));
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
          amount: group?.defaultPrice,
          paidUntil: defaultPaidUntil
        }
      }}
    />
  );
}
