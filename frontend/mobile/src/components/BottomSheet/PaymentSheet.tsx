import { useMutation } from '@apollo/client/react';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert, View } from 'react-native';
import { Button } from 'react-native-paper';
import { CustomBottomSheet } from '@/src/components/BottomSheet/CustomBottomSheet';
import { graphql } from '@/src/graphql/__generated__';
import { useAppTheme } from '@/src/hooks/useAppTheme';

const DELETE_PAYMENT = graphql(`
    mutation DeletePayment($id: UUID!) {
        deletePayment(id: $id) {
            id
        }
    }
`);

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

  const [deletePayment, { loading }] = useMutation(DELETE_PAYMENT, {
    variables: { id: paymentId },

    update(cache, { data }) {
      if (!data?.deletePayment) {
        return;
      }

      cache.evict({ id: cache.identify(data.deletePayment) });
      cache.gc();
    },

    onCompleted: router.back,

    onError: err => Alert.alert(t('error'), err.message)
  });

  return (
    <CustomBottomSheet
      visible={visible}
      onDismiss={onDismiss}
    >
      <View style={{ gap: 16, padding: 16 }}>
        <Button
          mode={'contained-tonal'}
          textColor={theme.colors.primary}
          buttonColor={theme.colors.surface}
          onPress={() => {
            router.push(
              `/(tabs)/students/${studentId}/payments/${paymentId}/edit`
            );
            onDismiss();
          }}
          disabled={loading}
        >
          {t('edit')}
        </Button>

        <Button
          mode={'contained-tonal'}
          textColor={theme.colors.error}
          buttonColor={theme.colors.tertiaryContainer}
          onPress={() => void deletePayment()}
          disabled={loading}
          loading={loading}
        >
          {t('delete')}
        </Button>
      </View>
    </CustomBottomSheet>
  );
};
