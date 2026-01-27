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

  const {
    data: student,
    isPending: studentPending,
    refetch
  } = api.useQuery('get', '/api/v1/students/{studentId}/details', {
    params: {
      path: {
        studentId
      }
    }
  });

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
            disabled: studentPending
          },
          {
            icon: 'account-edit',
            onPress: () => router.push(`/(tabs)/students/${studentId}/update`),
            disabled: studentPending
          },
          {
            icon: 'trash-can',
            onPress: () => handleDeletePress(),
            disabled: studentPending
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
            refreshing={studentPending}
            onRefresh={refetch}
          />
        }
        keyboardShouldPersistTaps='handled'
      >
        {student && (
          <>
            <StudentCard student={student} />

            <StudentPaymentsTable
              payments={student?.studentPayments ?? []}
              onRowPress={setPaymentIdSheet}
            />

            {student.groupId && (
              <VisitCalendar
                groupId={student.groupId}
                visitsWithLesson={student?.studentVisits ?? []}
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
