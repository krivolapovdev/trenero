import { useQueries } from '@tanstack/react-query';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Alert, RefreshControl, ScrollView } from 'react-native';
import { api } from '@/src/api';
import { PaymentSheet } from '@/src/components/BottomSheet/PaymentSheet';
import { VisitCalendar } from '@/src/components/Calendar';
import { StudentCard } from '@/src/components/Card';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { StudentPaymentsTable } from '@/src/components/StudentPaymentsTable';
import { useAppTheme } from '@/src/hooks/useAppTheme';

export default function StudentByIdScreen() {
  const { studentId } = useLocalSearchParams<{ studentId: string }>();
  const theme = useAppTheme();
  const router = useRouter();
  const { t } = useTranslation();

  const [paymentIdSheet, setPaymentIdSheet] = useState<string | null>(null);

  const queries = useQueries({
    queries: [
      api.queryOptions('get', `/api/v1/students/{studentId}`, {
        params: { path: { studentId } }
      }),

      api.queryOptions('get', `/api/v1/students/{studentId}/payments`, {
        params: { path: { studentId } }
      }),

      api.queryOptions('get', `/api/v1/students/{studentId}/visits`, {
        params: { path: { studentId } }
      }),

      api.queryOptions('get', `/api/v1/lessons`)
    ]
  });

  const student = queries[0].data;
  const studentPayments = queries[1].data ?? [];
  const studentVisits = queries[2].data;
  const allLessons = queries[3].data;

  const { mutate: deleteStudent, isPending: deleteStudentPending } =
    api.useMutation('delete', `/api/v1/students/{studentId}`, {
      onSuccess: () => router.back(),
      onError: err => Alert.alert(t('error'), err)
    });

  const handleDeletePress = () => {
    Alert.alert(t('deleteStudent'), t('deleteStudentConfirmation'), [
      { text: t('cancel'), style: 'cancel' },
      {
        text: t('delete'),
        style: 'destructive',
        onPress: () =>
          deleteStudent({
            params: { path: { studentId } }
          })
      }
    ]);
  };

  const isLoading = queries.some(q => q.isFetching) || deleteStudentPending;

  return (
    <>
      <CustomAppbar
        title={t('student')}
        mode='small'
        leftActions={[
          {
            icon: 'arrow-left',
            onPress: () => router.back(),
            disabled: deleteStudentPending
          }
        ]}
        rightActions={[
          {
            icon: 'account-cash',
            onPress: () =>
              router.push(`/(tabs)/students/${studentId}/payments/create`),
            disabled: isLoading
          },
          {
            icon: 'account-edit',
            onPress: () => router.push(`/(tabs)/students/${studentId}/update`),
            disabled: isLoading
          },
          {
            icon: 'trash-can',
            onPress: () => handleDeletePress(),
            disabled: isLoading
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
            refreshing={isLoading}
            onRefresh={() => Promise.all(queries.map(q => q.refetch()))}
          />
        }
        keyboardShouldPersistTaps='handled'
      >
        {student && studentPayments && studentVisits && allLessons && (
          <>
            <StudentCard {...student} />

            <StudentPaymentsTable
              payments={studentPayments}
              onRowPress={setPaymentIdSheet}
            />

            {student.groupId && (
              <VisitCalendar
                groupId={student.groupId}
                visits={studentVisits}
                lessons={allLessons}
              />
            )}
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
