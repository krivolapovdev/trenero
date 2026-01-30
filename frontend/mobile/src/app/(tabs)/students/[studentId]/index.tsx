import { useLocalSearchParams, useRouter } from 'expo-router';
import { useCallback, useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Alert, RefreshControl, ScrollView } from 'react-native';
import { api } from '@/src/api';
import { PaymentSheet } from '@/src/components/BottomSheet/PaymentSheet';
import { VisitCalendar } from '@/src/components/Calendar';
import { StudentCard } from '@/src/components/Card';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import { StudentPaymentsTable } from '@/src/components/StudentPaymentsTable';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { useCustomAsyncCallback } from '@/src/hooks/useCustomAsyncCallback';
import { useStudentsStore } from '@/src/stores/studentsStore';
import type { ApiError } from '@/src/types/error';

export default function StudentByIdScreen() {
  const { studentId } = useLocalSearchParams<{ studentId: string }>();
  const theme = useAppTheme();
  const router = useRouter();
  const { t } = useTranslation();

  const [paymentIdSheet, setPaymentIdSheet] = useState<string | null>(null);

  const recentStudents = useStudentsStore(state => state.recentStudents);
  const addStudent = useStudentsStore(state => state.addStudent);
  const removeStudent = useStudentsStore(state => state.removeStudent);
  const student = recentStudents.find(s => s.id === studentId);

  const {
    execute: fetchStudent,
    loading: studentLoading,
    error
  } = useCustomAsyncCallback(() =>
    api.GET('/api/v1/students/{studentId}/details', {
      params: { path: { studentId } }
    })
  );

  const { execute: deleteStudent, loading: deleteLoading } =
    useCustomAsyncCallback(() =>
      api.DELETE('/api/v1/students/{studentId}', {
        params: { path: { studentId } }
      })
    );

  const handleDeletePress = () => {
    Alert.alert(t('deleteStudent'), t('deleteStudentConfirmation'), [
      { text: t('cancel'), style: 'cancel' },
      {
        text: t('delete'),
        style: 'destructive',
        onPress: () =>
          void deleteStudent({})
            .then(() => removeStudent(studentId))
            .then(() => router.back())
            .catch(err => Alert.alert(t('error'), err.message))
      }
    ]);
  };

  const refreshData = useCallback(async () => {
    try {
      const data = await fetchStudent({});
      if (data) {
        addStudent(data);
      }
    } catch (err) {
      const errorData = err as ApiError;
      Alert.alert(t('error'), errorData.detail);
    }
  }, [fetchStudent, addStudent, t]);

  useEffect(() => {
    if (!student) {
      void refreshData();
    }
  }, [student, refreshData]);

  return (
    <>
      <CustomAppbar
        title={t('student')}
        mode='small'
        leftActions={[
          {
            icon: 'arrow-left',
            onPress: () => router.back(),
            disabled: deleteLoading
          }
        ]}
        rightActions={[
          {
            icon: 'account-cash',
            onPress: () =>
              router.push(`/(tabs)/students/${studentId}/payments/create`),
            disabled: studentLoading
          },
          {
            icon: 'account-edit',
            onPress: () => router.push(`/(tabs)/students/${studentId}/update`),
            disabled: studentLoading
          },
          {
            icon: 'trash-can',
            onPress: () => handleDeletePress(),
            disabled: studentLoading
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
            refreshing={studentLoading}
            onRefresh={refreshData}
          />
        }
        keyboardShouldPersistTaps='handled'
      >
        <OptionalErrorMessage error={error?.message} />

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
