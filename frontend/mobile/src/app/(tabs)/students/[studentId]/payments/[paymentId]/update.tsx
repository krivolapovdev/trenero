import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import * as R from 'remeda';
import { api } from '@/src/api';
import type { components } from '@/src/api/generated/openapi';
import {
  PaymentForm,
  type PaymentFormValues
} from '@/src/components/Form/PaymentForm';

export default function UpdatePaymentScreen() {
  const router = useRouter();
  const { t } = useTranslation();
  const { paymentId } = useLocalSearchParams<{
    studentId: string;
    paymentId: string;
  }>();

  const { data: payment, isFetching: queryFetching } = api.useQuery(
    'get',
    `/api/v1/payments/{paymentId}`,
    {
      params: { path: { paymentId } }
    }
  );

  const { mutate: updatePayment, isPending: updatePaymentPending } =
    api.useMutation('patch', `/api/v1/payments/{paymentId}`, {
      onSuccess: router.back,
      onError: err => Alert.alert('Error', err)
    });

  const handleSubmit = (values: PaymentFormValues) => {
    if (!payment || queryFetching || updatePaymentPending) {
      return;
    }

    const request: components['schemas']['UpdatePaymentRequest'] = {};

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

    updatePayment({
      params: { path: { paymentId } },
      body: request
    });
  };

  return (
    <PaymentForm
      title={t('editPayment')}
      initialData={{
        payment
      }}
      queryLoading={queryFetching}
      mutationLoading={updatePaymentPending}
      onBack={router.back}
      onSubmit={handleSubmit}
    />
  );
}
