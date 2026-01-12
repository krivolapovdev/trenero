import dayjs from 'dayjs';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { ScrollView, StyleSheet } from 'react-native';
import { Text } from 'react-native-paper';
import { DatePickerModal, TimePickerModal } from 'react-native-paper-dates';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { StudentAttendancePicker } from '@/src/components/StudentAttendancePicker';
import { SurfaceCard } from '@/src/components/SurfaceCard';
import type { GetLessonQuery } from '@/src/graphql/__generated__/graphql';
import { useAppTheme } from '@/src/hooks/useAppTheme';

export type LessonFormValues = {
  startDateTime: string;
  students: { studentId: string; present: boolean }[];
};

type Props = {
  title: string;
  initialData?: Partial<GetLessonQuery['lesson']> | null;
  availableStudents: { id: string; fullName: string }[];
  onSubmit: (values: LessonFormValues) => void;
  onBack: () => void;
  loading: boolean;
};

export const LessonForm = ({
  title,
  initialData,
  availableStudents,
  onSubmit,
  onBack,
  loading
}: Readonly<Props>) => {
  const { i18n } = useTranslation();
  const theme = useAppTheme();

  const [startDateTime, setStartDateTime] = useState(
    initialData ? dayjs(initialData.startDateTime) : dayjs()
  );

  const [visibleTimePicker, setVisibleTimePicker] = useState(false);
  const [visibleDatePicker, setVisibleDatePicker] = useState(false);

  const [attendanceStatus, setAttendanceStatus] = useState<
    Record<string, boolean>
  >(() =>
    initialData?.attendances
      ? Object.fromEntries(
          initialData.attendances.map(a => [a.student.id, a.present])
        )
      : {}
  );

  const handleSubmit = () => {
    const students = Object.entries(attendanceStatus).map(
      ([studentId, present]) => ({
        studentId,
        present
      })
    );

    onSubmit({
      startDateTime: startDateTime.toISOString(),
      students
    });
  };

  return (
    <>
      <CustomAppbar
        title={title}
        leftActions={[
          { icon: 'arrow-left', onPress: onBack, disabled: loading }
        ]}
        rightActions={[
          { icon: 'content-save', disabled: loading, onPress: handleSubmit }
        ]}
      />

      <ScrollView
        contentContainerStyle={styles.container}
        style={{ flex: 1, backgroundColor: theme.colors.surfaceVariant }}
      >
        <SurfaceCard style={styles.dateTimeRow}>
          <Text
            variant='bodyLarge'
            onPress={() => setVisibleDatePicker(true)}
            style={{ color: theme.colors.primary }}
          >
            {startDateTime.format('DD/MM/YYYY')}
          </Text>

          <Text
            variant='bodyLarge'
            onPress={() => setVisibleTimePicker(true)}
            style={{ color: theme.colors.primary }}
          >
            {startDateTime.format('HH:mm')}
          </Text>
        </SurfaceCard>

        <SurfaceCard>
          <StudentAttendancePicker
            students={availableStudents}
            attendanceStatus={attendanceStatus}
            setAttendanceStatus={setAttendanceStatus}
          />
        </SurfaceCard>
      </ScrollView>

      <TimePickerModal
        locale={i18n.language}
        visible={visibleTimePicker}
        onDismiss={() => setVisibleTimePicker(false)}
        onConfirm={({ hours, minutes }) => {
          setStartDateTime(prev =>
            prev.set('hours', hours).set('minutes', minutes)
          );
          setVisibleTimePicker(false);
        }}
        hours={startDateTime.hour()}
        minutes={startDateTime.minute()}
        use24HourClock={true}
      />

      <DatePickerModal
        locale={i18n.language}
        mode='single'
        visible={visibleDatePicker}
        onDismiss={() => setVisibleDatePicker(false)}
        date={startDateTime.toDate()}
        onConfirm={({ date }) => {
          if (date) {
            setStartDateTime(prev =>
              prev
                .set('date', date.getDate())
                .set('month', date.getMonth())
                .set('year', date.getFullYear())
            );
          }
          setVisibleDatePicker(false);
        }}
      />
    </>
  );
};

const styles = StyleSheet.create({
  container: { padding: 16, gap: 16 },
  dateTimeRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between'
  }
});
