import dayjs from 'dayjs';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useEffect, useState } from 'react';
import { useAsyncCallback } from 'react-async-hook';
import { useTranslation } from 'react-i18next';
import { Alert, RefreshControl, ScrollView } from 'react-native';
import { Text } from 'react-native-paper';
import { studentService } from '@/src/api/services/student/studentService';
import { PaymentSheet } from '@/src/components/BottomSheet/PaymentSheet';
import { VisitCalendar } from '@/src/components/Calendar';
import { CalendarControls } from '@/src/components/Calendar/CustomCalendar';
import { StudentCard } from '@/src/components/Card';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import { StudentPaymentsTable } from '@/src/components/StudentPaymentsTable';
import { SurfaceCard } from '@/src/components/SurfaceCard';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { useStudentsStore } from '@/src/stores/studentsStore';
import type { StudentDetails, StudentOverview } from '@/src/types/student';

const isFullDetails = (
  s: StudentOverview | StudentDetails | undefined
): s is StudentDetails => (s ? 'studentPayments' in s : false);

export default function StudentByIdScreen() {
  const { studentId } = useLocalSearchParams<{ studentId: string }>();
  const theme = useAppTheme();
  const router = useRouter();
  const { t } = useTranslation();

  const [paymentIdSheet, setPaymentIdSheet] = useState<string | null>(null);

  const addStudent = useStudentsStore(state => state.addStudent);
  const removeStudent = useStudentsStore(state => state.removeStudent);
  const student = useStudentsStore(state => state.allStudents[studentId]);

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
  } = useAsyncCallback(async () => {
    await studentService.delete(studentId);
    removeStudent(studentId);
    router.back();
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

  const hasDetails = isFullDetails(student);

  useEffect(() => {
    if (!hasDetails) {
      void fetchStudent();
    }
  }, [fetchStudent, hasDetails]);

  useEffect(() => {
    if (deleteError) {
      Alert.alert(t('error'), deleteError.message);
    }
  }, [deleteError, t]);

  const studentGroup = hasDetails
    ? student.groupsHistory.find(g => g.isCurrent)?.group
    : undefined;

  const [currentMonth, setCurrentMonth] = useState(dayjs());

  const goPrevMonth = () => setCurrentMonth(prev => prev.subtract(1, 'month'));
  const goNextMonth = () => setCurrentMonth(prev => prev.add(1, 'month'));

  return (
    <>
      <CustomAppbar
        title={t('student')}
        mode='small'
        leftActions={[
          {
            icon: 'arrow-left',
            onPress: router.back,
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
            onPress: handleDeletePress,
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

        {hasDetails && (
          <>
            <StudentCard
              student={{
                ...student,
                studentGroup
              }}
            />

            <StudentPaymentsTable
              payments={student?.studentPayments ?? []}
              onRowPress={setPaymentIdSheet}
            />

            <SurfaceCard>
              <Text
                variant='bodyLarge'
                style={{ textAlign: 'center', marginTop: 8 }}
              >
                {currentMonth.format('MMMM YYYY')}
              </Text>

              {student.groupsHistory.map(({ group, visits, isCurrent }) => (
                <SurfaceCard key={group.id}>
                  <Text
                    variant='bodyLarge'
                    style={{
                      marginBottom: 8,
                      textAlign: 'center',
                      backgroundColor: isCurrent
                        ? theme.colors.primaryContainer
                        : theme.colors.errorContainer
                    }}
                  >
                    {group.name}
                  </Text>

                  <VisitCalendar
                    groupId={group.id}
                    visitsWithLesson={visits}
                    currentMonth={currentMonth}
                  />
                </SurfaceCard>
              ))}

              <CalendarControls
                currentMonth={currentMonth}
                onPrev={goPrevMonth}
                onNext={goNextMonth}
                disableNext={currentMonth.isSame(dayjs(), 'month')}
              />
            </SurfaceCard>
          </>
        )}
      </ScrollView>

      <PaymentSheet
        visible={Boolean(paymentIdSheet)}
        onDismiss={() => {
          setPaymentIdSheet(null);
          void fetchStudent();
        }}
        paymentId={paymentIdSheet ?? ''}
      />
    </>
  );
}
