import { useLocalSearchParams, useRouter } from 'expo-router';
import { useEffect, useState } from 'react';
import { useAsyncCallback } from 'react-async-hook';
import { useTranslation } from 'react-i18next';
import { Alert, RefreshControl, ScrollView } from 'react-native';
import { studentService } from '@/src/api/services/student/studentService';
import { PaymentSheet } from '@/src/components/BottomSheet/PaymentSheet';
import { VisitCalendar } from '@/src/components/Calendar';
import { StudentCard } from '@/src/components/Card';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import { StudentPaymentsTable } from '@/src/components/StudentPaymentsTable';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { useStudentsStore } from '@/src/stores/studentsStore';

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
    error: fetchError
  } = useAsyncCallback(async () => {
    const data = await studentService.getDetails(studentId);
    addStudent(data);
    return data;
  });

  const {
    execute: deleteStudent,
    loading: deleteLoading,
    error: deleteError
  } = useAsyncCallback(() => studentService.delete(studentId));

  const handleDeletePress = () => {
    Alert.alert(t('deleteStudent'), t('deleteStudentConfirmation'), [
      { text: t('cancel'), style: 'cancel' },
      {
        text: t('delete'),
        style: 'destructive',
        onPress: () =>
          void deleteStudent()
            .then(() => removeStudent(studentId))
            .then(() => router.back())
      }
    ]);
  };

  useEffect(() => {
    if (!student) {
      void fetchStudent();
    }
  }, [student, fetchStudent]);

  useEffect(() => {
    if (deleteError) {
      Alert.alert(t('error'), deleteError.message);
    }
  }, [deleteError, t]);

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
            onRefresh={fetchStudent}
          />
        }
        keyboardShouldPersistTaps='handled'
      >
        <OptionalErrorMessage error={fetchError?.message} />

        {student && (
          <>
            <StudentCard student={student} />

            <StudentPaymentsTable
              payments={student?.studentPayments ?? []}
              onRowPress={setPaymentIdSheet}
            />

            {student.studentGroup && (
              <VisitCalendar
                groupId={student.studentGroup.id}
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
