import type { Reference } from '@apollo/client';
import { useMutation } from '@apollo/client/react';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { t } from 'i18next';
import { Alert } from 'react-native';
import {
  PaymentForm,
  type PaymentFormValues
} from '@/src/components/Form/PaymentForm';
import { graphql } from '@/src/graphql/__generated__';

const CREATE_PAYMENT = graphql(`
    mutation CreatePayment($input: CreatePaymentInput!) {
        createPayment(input: $input) {
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

export default function CreatePaymentScreen() {
  const router = useRouter();
  const { studentId } = useLocalSearchParams<{ studentId: string }>();

  const [createPayment, { loading }] = useMutation(CREATE_PAYMENT, {
    update(cache, { data }) {
      const newPayment = data?.createPayment;

      if (!newPayment) {
        return;
      }

      const identify = cache.identify(newPayment);

      if (!identify) {
        return;
      }

      cache.modify({
        fields: {
          payments: (existingPayments: readonly Reference[] = []) => [
            { __ref: identify },
            ...existingPayments
          ]
        }
      });
    },

    onCompleted: () => router.back(),

    onError: err => Alert.alert(t('error'), err.message)
  });

  const handleSubmit = (values: PaymentFormValues) => {
    const input = {
      studentId,
      ...values
    };

    void createPayment({
      variables: {
        input
      }
    });
  };

  return (
    <PaymentForm
      title={t('addPayment')}
      onSubmit={handleSubmit}
      onBack={() => router.back()}
      loading={loading}
    />
  );
}
