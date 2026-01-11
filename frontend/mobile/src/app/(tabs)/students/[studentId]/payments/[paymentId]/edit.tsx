import type { Reference } from '@apollo/client';
import { useMutation, useQuery } from '@apollo/client/react';
import dayjs from 'dayjs';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import { LoadingSpinner } from '@/src/components/LoadingSpinner';
import {
  PaymentForm,
  type PaymentFormValues
} from '@/src/components/PaymentForm';
import { graphql } from '@/src/graphql/__generated__';
import { GET_PAYMENT } from '@/src/graphql/queries';

const EDIT_PAYMENT = graphql(`
    mutation EditPayment($id: UUID!, $input: CreatePaymentInput!) {
        editPayment(id: $id, input: $input) {
            ...PaymentFields
            student {
                id
                payments {
                    id
                }
            }
        }
    }
`);

export default function EditPaymentScreen() {
  const router = useRouter();
  const { t } = useTranslation();
  const { studentId, paymentId } = useLocalSearchParams<{
    studentId: string;
    paymentId: string;
  }>();

  console.log(studentId);
  console.log(paymentId);

  const { data, loading } = useQuery(GET_PAYMENT, {
    variables: { id: paymentId }
    // fetchPolicy: 'cache-first'
  });

  const [updatePayment, resultUpdatePayment] = useMutation(EDIT_PAYMENT, {
    update(cache, { data }) {
      const updatedPayment = data?.editPayment;

      if (!updatedPayment) {
        return;
      }

      const identify = cache.identify(updatedPayment);

      if (!identify) {
        return;
      }

      cache.modify({
        fields: {
          payments: (existingRefs: readonly Reference[] = []) =>
            existingRefs.map(ref =>
              ref.__ref === identify ? { __ref: identify } : ref
            )
        }
      });
    },
    onCompleted: () => router.back(),
    onError: err => Alert.alert('Error', err.message)
  });

  const handleSubmit = (values: PaymentFormValues) => {
    if (resultUpdatePayment.loading) {
      return;
    }

    const input = { studentId, ...values };

    void updatePayment({ variables: { id: paymentId, input } });
  };

  if (loading) {
    return <LoadingSpinner />;
  }

  return (
    <PaymentForm
      title={t('editPayment')}
      initialData={{
        amount: data?.payment?.amount ?? '',
        lessonsPerPayment: data?.payment?.lessonsPerPayment ?? 0,
        date: data?.payment?.date ?? dayjs().format('DD/MM/YYYY')
      }}
      loading={resultUpdatePayment.loading}
      onBack={() => router.back()}
      onSubmit={handleSubmit}
    />
  );
}
