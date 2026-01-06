import {useMutation, useQuery} from '@apollo/client/react';
import dayjs from 'dayjs';
import {useLocalSearchParams, useRouter} from 'expo-router';
import {useState} from 'react';
import {Alert, ScrollView} from 'react-native';
import {CustomAppbar} from '@/src/components/CustomAppbar';
import {CustomTextInput} from '@/src/components/CustomTextInput';
import {graphql} from '@/src/graphql/__generated__';
import {PaymentFieldsFragmentDoc} from '@/src/graphql/__generated__/graphql';
import {GET_STUDENT} from '@/src/graphql/queries';
import {formatDateInput} from '@/src/helpers/formatDateInput';
import {formatPriceInput} from '@/src/helpers/formatPriceInput';
import {parsePastOrTodayDateFromInput} from '@/src/helpers/parsePastOrTodayDateFromInput';
import {useAppTheme} from '@/src/hooks/useAppTheme';

const CREATE_PAYMENT = graphql(`
    mutation CreatePayment($input: CreatePaymentInput!) {
        createPayment(input: $input) {
            ...PaymentFields
        }
    }
`);

export default function CreatePaymentScreen() {
  const router = useRouter();
  const theme = useAppTheme();
  const {id: studentId} = useLocalSearchParams<{ id: string }>();
  const [date, setDate] = useState(dayjs().format('DD/MM/YYYY'));

  const {data} = useQuery(GET_STUDENT, {
    variables: {id: studentId},
    fetchPolicy: 'cache-first'
  });

  const [amount, setAmount] = useState(
      data?.student?.group?.defaultPrice || ''
  );
  const [lessonsPerPayment, setLessonsPerPayment] = useState<number | null>(
      null
  );

  const [createPayment, {loading}] = useMutation(CREATE_PAYMENT, {
    update(cache, {data}) {
      const newPayment = data?.createPayment;

      if (!newPayment) {
        return;
      }

      const newPaymentRef = cache.writeFragment({
        data: newPayment,
        fragment: PaymentFieldsFragmentDoc
      });

      cache.modify({
        fields: {
          payments: (existingPayments = []) => [
            newPaymentRef,
            ...existingPayments
          ]
        }
      });

      cache.modify({
        id: cache.identify({__typename: 'Student', id: studentId}),
        fields: {
          payments: (existingPayments = []) => [
            newPaymentRef,
            ...existingPayments
          ]
        }
      });
    },

    onCompleted: () => router.back(),

    onError: err => Alert.alert('Error', err.message)
  });

  const handleSubmit = () => {
    if (!lessonsPerPayment) {
      Alert.alert('Error', 'Please enter the number of lessons.');
      return;
    }

    const parsedDate = parsePastOrTodayDateFromInput(date);
    if (!parsedDate) {
      Alert.alert('Error', 'Invalid date format.');
      return;
    }

    const input = {
      studentId,
      amount: amount.toString(),
      lessonsPerPayment: lessonsPerPayment,
      date: parsedDate.format('YYYY-MM-DD')
    };

    void createPayment({
      variables: {
        input
      }
    });
  };

  return (
      <>
        <CustomAppbar
            title='Add Payment'
            leftActions={[
              {
                icon: 'arrow-left',
                onPress: () => router.back(),
                disabled: loading
              }
            ]}
            rightActions={[
              {
                icon: 'content-save',
                disabled:
                    loading || !amount || !lessonsPerPayment || date?.length !== 10,
                onPress: handleSubmit
              }
            ]}
        />

        <ScrollView
            contentContainerStyle={{padding: 16, gap: 16}}
            showsVerticalScrollIndicator={false}
            style={{
              flex: 1,
              backgroundColor: theme.colors.surfaceVariant
            }}
        >
          <CustomTextInput
              label='Amount *'
              keyboardType='numeric'
              value={amount}
              onChangeText={text => setAmount(formatPriceInput(text))}
              disabled={loading}
          />

          <CustomTextInput
              label='Lessons per payment *'
              keyboardType='numeric'
              value={lessonsPerPayment?.toString() ?? ''}
              onChangeText={text =>
                  setLessonsPerPayment(
                      Number.isNaN(Number(text)) ? null : Number(text)
                  )
              }
              disabled={loading}
          />

          <CustomTextInput
              label='Date *'
              keyboardType='numeric'
              maxLength={10}
              value={date}
              onChangeText={text => setDate(formatDateInput(text))}
          />
        </ScrollView>
      </>
  );
}
