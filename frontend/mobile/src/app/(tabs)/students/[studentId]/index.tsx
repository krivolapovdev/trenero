import { useMutation, useQuery } from '@apollo/client/react';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Alert, RefreshControl, ScrollView } from 'react-native';
import { PaymentSheet } from '@/src/components/BottomSheet/PaymentSheet';
import { VisitCalendar } from '@/src/components/Calendar';
import { StudentCard } from '@/src/components/Card';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import { StudentPaymentsTable } from '@/src/components/StudentPaymentsTable';
import { graphql } from '@/src/graphql/__generated__';
import { GET_STUDENT } from '@/src/graphql/queries';
import { useAppTheme } from '@/src/hooks/useAppTheme';

const DELETE_STUDENT = graphql(`
    mutation DeleteStudent($id: UUID!) {
        deleteStudent(id: $id) {
            id
        }
    }
`);

export default function StudentByIdScreen() {
  const { studentId } = useLocalSearchParams<{ studentId: string }>();
  const theme = useAppTheme();
  const router = useRouter();
  const { t } = useTranslation();

  const [paymentIdSheet, setPaymentIdSheet] = useState<string | null>(null);

  const { data, loading, error, refetch } = useQuery(GET_STUDENT, {
    variables: { id: studentId },
    fetchPolicy: __DEV__ ? 'cache-first' : 'cache-and-network'
  });

  const [deleteStudent, resultDeleteStudent] = useMutation(DELETE_STUDENT, {
    variables: { id: studentId },

    update(cache, { data }) {
      if (!data?.deleteStudent) {
        return;
      }

      cache.evict({ id: cache.identify(data.deleteStudent) });
      cache.gc();
    },

    onCompleted: router.back,

    onError: err => Alert.alert(t('error'), err.message)
  });

  const handleDeletePress = () => {
    Alert.alert(t('deleteStudent'), t('deleteStudentConfirmation'), [
      { text: t('cancel'), style: 'cancel' },
      {
        text: t('delete'),
        style: 'destructive',
        onPress: () => void deleteStudent()
      }
    ]);
  };

  const student = data?.student;

  return (
    <>
      <CustomAppbar
        title={t('student')}
        mode='small'
        leftActions={[
          {
            icon: 'arrow-left',
            onPress: () => router.back(),
            disabled: resultDeleteStudent.loading
          }
        ]}
        rightActions={[
          {
            icon: 'account-cash',
            onPress: () =>
              router.push(`/(tabs)/students/${studentId}/payments/create`),
            disabled: loading || resultDeleteStudent.loading
          },
          {
            icon: 'account-edit',
            onPress: () => router.push(`/(tabs)/students/${studentId}/update`),
            disabled: loading || resultDeleteStudent.loading
          },
          {
            icon: 'trash-can',
            onPress: () => handleDeletePress(),
            disabled: loading || resultDeleteStudent.loading
          }
        ]}
      />

      <ScrollView
        contentContainerStyle={{ padding: 16, gap: 16 }}
        showsVerticalScrollIndicator={false}
        style={{
          flex: 1,
          backgroundColor: theme.colors.surfaceVariant
        }}
        refreshControl={
          <RefreshControl
            refreshing={loading}
            onRefresh={refetch}
          />
        }
        keyboardShouldPersistTaps='handled'
      >
        <OptionalErrorMessage error={error?.message} />

        {student && (
          <>
            <StudentCard {...student} />

            <StudentPaymentsTable
              payments={student.payments}
              onRowPress={setPaymentIdSheet}
            />

            <VisitCalendar
              groupId={student?.group?.id ?? ''}
              visits={student.visits}
            />
          </>
        )}
      </ScrollView>

      <PaymentSheet
        visible={Boolean(paymentIdSheet)}
        onDismiss={() => setPaymentIdSheet(null)}
        paymentId={paymentIdSheet ?? ''}
      />
    </>
  );
}
