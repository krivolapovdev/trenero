import { useMutation } from '@apollo/client/react';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { t } from 'i18next';
import { Alert } from 'react-native';
import {
  PaymentForm,
  type PaymentFormValues
} from '@/src/components/Form/PaymentForm';
import { graphql } from '@/src/graphql/__generated__';
import { GET_GROUPS, GET_STUDENTS } from '@/src/graphql/queries';

const CREATE_PAYMENT = graphql(`
    mutation CreatePayment($input: CreatePaymentInput!) {
        createPayment(input: $input) {
            ...PaymentDetailsFields
        }
    }
`);

export default function CreatePaymentScreen() {
  const router = useRouter();
  const { studentId } = useLocalSearchParams<{ studentId: string }>();

  const [createPayment, { loading }] = useMutation(CREATE_PAYMENT, {
    refetchQueries: [GET_GROUPS, GET_STUDENTS],

    awaitRefetchQueries: true,

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
