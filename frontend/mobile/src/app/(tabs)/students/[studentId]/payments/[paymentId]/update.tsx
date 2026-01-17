import { useMutation, useQuery } from '@apollo/client/react';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import * as R from 'remeda';
import {
  PaymentForm,
  type PaymentFormValues
} from '@/src/components/Form/PaymentForm';
import { graphql } from '@/src/graphql/__generated__';
import type { UpdatePaymentInput } from '@/src/graphql/__generated__/graphql';
import { GET_PAYMENT, GET_STUDENTS } from '@/src/graphql/queries';

const UPDATE_PAYMENT = graphql(`
    mutation UpdatePayment($id: UUID!, $input: UpdatePaymentInput!) {
        updatePayment(id: $id, input: $input) {
            ...PaymentDetailsFields
        }
    }
`);

export default function UpdatePaymentScreen() {
  const router = useRouter();
  const { t } = useTranslation();
  const { paymentId } = useLocalSearchParams<{
    studentId: string;
    paymentId: string;
  }>();

  const { data, loading: queryLoading } = useQuery(GET_PAYMENT, {
    variables: { id: paymentId },
    fetchPolicy: 'cache-first'
  });

  const [updatePayment, { loading: mutationLoading }] = useMutation(
    UPDATE_PAYMENT,
    {
      refetchQueries: [GET_STUDENTS],

      awaitRefetchQueries: true,

      onCompleted: () => router.back(),

      onError: err => Alert.alert('Error', err.message)
    }
  );
  const handleSubmit = (values: PaymentFormValues) => {
    const payment = data?.payment;

    if (!payment || queryLoading || mutationLoading) {
      return;
    }

    const input: UpdatePaymentInput = {};

    if (values.amount !== payment.amount) {
      input.amount = values.amount;
    }

    if (values.lessonsPerPayment !== payment.lessonsPerPayment) {
      input.lessonsPerPayment = values.lessonsPerPayment;
    }

    if (values.date !== payment.date) {
      input.date = values.date;
    }

    if (R.isEmpty(input)) {
      router.back();
      return;
    }

    void updatePayment({
      variables: {
        id: paymentId,
        input
      }
    });
  };

  const initialData = useMemo(() => data?.payment, [data?.payment]);

  return (
    <PaymentForm
      title={t('editPayment')}
      initialData={initialData}
      queryLoading={queryLoading}
      mutationLoading={mutationLoading}
      onBack={router.back}
      onSubmit={handleSubmit}
    />
  );
}
