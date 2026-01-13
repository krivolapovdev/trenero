import { useMutation, useQuery } from '@apollo/client/react';
import dayjs from 'dayjs';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import {
  PaymentForm,
  type PaymentFormValues
} from '@/src/components/Form/PaymentForm';
import { LoadingSpinner } from '@/src/components/LoadingSpinner';
import { graphql } from '@/src/graphql/__generated__';
import { GET_GROUPS, GET_PAYMENT, GET_STUDENTS } from '@/src/graphql/queries';

const EDIT_PAYMENT = graphql(`
    mutation EditPayment($id: UUID!, $input: CreatePaymentInput!) {
        editPayment(id: $id, input: $input) {
            ...PaymentDetailsFields
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

  const { data, loading: queryLoading } = useQuery(GET_PAYMENT, {
    variables: { id: paymentId },
    fetchPolicy: 'cache-first'
  });

  const [editPayment, { loading: mutationLoading }] = useMutation(
    EDIT_PAYMENT,
    {
      refetchQueries: [GET_GROUPS, GET_STUDENTS],

      awaitRefetchQueries: true,

      onCompleted: () => router.back(),

      onError: err => Alert.alert('Error', err.message)
    }
  );

  const handleSubmit = (values: PaymentFormValues) => {
    if (mutationLoading) {
      return;
    }

    const input = { studentId, ...values };

    void editPayment({ variables: { id: paymentId, input } });
  };

  if (queryLoading) {
    return <LoadingSpinner />;
  }

  return (
    <PaymentForm
      title={t('editPayment')}
      initialData={{
        amount: data?.payment?.amount,
        lessonsPerPayment: data?.payment?.lessonsPerPayment ?? 0,
        date: data?.payment?.date ?? dayjs().format('DD/MM/YYYY')
      }}
      loading={mutationLoading}
      onBack={() => router.back()}
      onSubmit={handleSubmit}
    />
  );
}
