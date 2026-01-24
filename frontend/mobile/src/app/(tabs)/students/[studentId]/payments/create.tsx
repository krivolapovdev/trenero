import { useLocalSearchParams, useRouter } from 'expo-router';
import { t } from 'i18next';
import { Alert } from 'react-native';
import { api } from '@/src/api';
import {
  PaymentForm,
  type PaymentFormValues
} from '@/src/components/Form/PaymentForm';

export default function CreatePaymentScreen() {
  const router = useRouter();
  const { studentId } = useLocalSearchParams<{ studentId: string }>();

  const { mutate: createPayment, isPending: createPaymentPending } =
    api.useMutation('post', '/api/v1/payments', {
      onSuccess: router.back,
      onError: err => Alert.alert(t('error'), err)
    });

  const handleSubmit = (values: PaymentFormValues) => {
    if (createPaymentPending) {
      return;
    }

    createPayment({
      body: {
        studentId,
        ...values
      }
    });
  };

  return (
    <PaymentForm
      title={t('addPayment')}
      onSubmit={handleSubmit}
      onBack={() => router.back()}
      queryLoading={false}
      mutationLoading={createPaymentPending}
    />
  );
}
