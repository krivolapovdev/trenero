import { useMutation } from '@apollo/client/react';
import { memo, useEffect, useState } from 'react';
import { Alert, StyleSheet, View } from 'react-native';
import { Button } from 'react-native-paper';
import { AppBottomSheet } from '@/src/components/AppBottomSheet';
import { CustomTextInput } from '@/src/components/CustomTextInput';
import { graphql } from '@/src/graphql/__generated__';
import { PaymentFieldsFragmentDoc } from '@/src/graphql/__generated__/graphql';
import { formatPrice } from '@/src/helpers/formatPrice';

const CREATE_PAYMENT = graphql(`
    mutation CreatePayment($input: CreatePaymentInput!) {
        createPayment(input: $input) {
            ...PaymentFields
        }
    }
`);

type Props = {
  visible: boolean;
  onDismiss: () => void;
  studentId: string;
  defaultPrice?: string | null;
};

export const CreatePaymentSheet = memo(
  ({ visible, onDismiss, studentId, defaultPrice }: Readonly<Props>) => {
    const [amount, setAmount] = useState(defaultPrice ?? '');

    const [createPayment, { loading }] = useMutation(CREATE_PAYMENT, {
      update(cache, { data }) {
        const newPayment = data?.createPayment;

        if (!newPayment) {
          return;
        }

        cache.modify({
          fields: {
            payments(existingPayments = []) {
              const newPaymentRef = cache.writeFragment({
                data: newPayment,
                fragment: PaymentFieldsFragmentDoc
              });
              return [newPaymentRef, ...existingPayments];
            }
          }
        });
      },

      onCompleted: () => {
        setAmount('');
        onDismiss();
      },

      onError: err => {
        Alert.alert('Error', err.message);
      }
    });

    useEffect(() => {
      if (visible) {
        setAmount(defaultPrice ?? '');
      }
    }, [defaultPrice, visible]);

    const handleSubmit = () => {
      void createPayment({
        variables: {
          input: {
            studentId,
            amount: amount.toString()
          }
        }
      });
    };

    return (
      <AppBottomSheet
        visible={visible}
        onDismiss={onDismiss}
      >
        <CustomTextInput
          label='Amount'
          keyboardType='numeric'
          value={amount}
          onChangeText={text => setAmount(formatPrice(text))}
          disabled={loading}
        />

        <View style={styles.footer}>
          <Button
            mode='contained'
            onPress={handleSubmit}
            loading={loading}
            disabled={loading || !amount}
          >
            Add payment
          </Button>
        </View>
      </AppBottomSheet>
    );
  }
);

const styles = StyleSheet.create({
  footer: {
    flexDirection: 'row',
    columnGap: 12,
    justifyContent: 'flex-end',
    marginBottom: 10
  }
});
