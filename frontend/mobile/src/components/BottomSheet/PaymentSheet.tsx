import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert, View } from 'react-native';
import { Button } from 'react-native-paper';
import { api } from '@/src/api';
import { CustomBottomSheet } from '@/src/components/BottomSheet/CustomBottomSheet';
import { useAppTheme } from '@/src/hooks/useAppTheme';

type Props = {
  paymentId: string;
  visible: boolean;
  onDismiss: () => void;
};

export const PaymentSheet = ({
  paymentId,
  visible,
  onDismiss
}: Readonly<Props>) => {
  const { t } = useTranslation();
  const theme = useAppTheme();
  const router = useRouter();
  const { studentId } = useLocalSearchParams<{
    studentId: string;
  }>();

  const { mutate: deletePayment, isPending: deletePaymentPending } =
    api.useMutation('delete', `/api/v1/payments/{paymentId}`, {
      onSuccess: onDismiss,
      onError: err => Alert.alert(t('error'), err)
    });

  return (
    <CustomBottomSheet
      visible={visible}
      onDismiss={onDismiss}
    >
      <View style={{ gap: 16, padding: 16 }}>
        <Button
          mode='contained-tonal'
          textColor={theme.colors.primary}
          buttonColor={theme.colors.surface}
          onPress={() => {
            router.push(
              `/(tabs)/students/${studentId}/payments/${paymentId}/update`
            );
            onDismiss();
          }}
          disabled={deletePaymentPending}
        >
          {t('edit')}
        </Button>

        <Button
          mode='contained-tonal'
          textColor={theme.colors.error}
          buttonColor={theme.colors.tertiaryContainer}
          onPress={() =>
            deletePayment({
              params: { path: { paymentId } }
            })
          }
          disabled={deletePaymentPending}
          loading={deletePaymentPending}
        >
          {t('delete')}
        </Button>
      </View>
    </CustomBottomSheet>
  );
};
