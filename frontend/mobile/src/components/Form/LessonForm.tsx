import dayjs from 'dayjs';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { RefreshControl, ScrollView, StyleSheet } from 'react-native';
import { Text } from 'react-native-paper';
import { DatePickerModal, TimePickerModal } from 'react-native-paper-dates';
import type { components } from '@/src/api/generated/openapi';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { StudentVisitPicker } from '@/src/components/StudentVisitPicker';
import { SurfaceCard } from '@/src/components/SurfaceCard';
import { useAppTheme } from '@/src/hooks/useAppTheme';

export type LessonFormValues = {
  startDateTime: string;
  students: { studentId: string; present: boolean }[];
};

type LessonFormInitialData = {
  lesson?: components['schemas']['LessonResponse'];
  groupStudents?: components['schemas']['StudentResponse'][];
  visits?: components['schemas']['VisitResponse'][];
};

type Props = {
  title: string;
  queryLoading: boolean;
  mutationLoading?: boolean;
  initialData?: LessonFormInitialData | null;
  onSubmit: (values: LessonFormValues) => void;
  onBack: () => void;
};

export const LessonForm = ({
  title,
  queryLoading,
  mutationLoading = false,
  initialData,
  onSubmit,
  onBack
}: Readonly<Props>) => {
  const { i18n } = useTranslation();
  const theme = useAppTheme();

  const [startDateTime, setStartDateTime] = useState(dayjs());
  const [visitStatus, setVisitStatus] = useState<Record<string, boolean>>({});

  const [visibleTimePicker, setVisibleTimePicker] = useState(false);
  const [visibleDatePicker, setVisibleDatePicker] = useState(false);

  const isLoading = queryLoading || mutationLoading;

  const handleSubmit = () => {
    if (isLoading) {
      return;
    }

    const students = Object.entries(visitStatus).map(
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

  useEffect(() => {
    if (initialData) {
      if (initialData.lesson?.startDateTime) {
        setStartDateTime(dayjs(initialData.lesson.startDateTime));
      }

      if (initialData.visits) {
        setVisitStatus(
          Object.fromEntries(
            initialData.visits.map(visit => [visit.studentId, visit.present])
          )
        );
      }
    }
  }, [initialData]);

  return (
    <>
      <CustomAppbar
        title={title}
        leftActions={[
          { icon: 'arrow-left', onPress: onBack, disabled: mutationLoading }
        ]}
        rightActions={[
          {
            icon: 'content-save',
            disabled: isLoading,
            onPress: handleSubmit
          }
        ]}
      />

      <ScrollView
        contentContainerStyle={styles.container}
        style={{ flex: 1, backgroundColor: theme.colors.surfaceVariant }}
        refreshControl={<RefreshControl refreshing={isLoading} />}
      >
        <SurfaceCard style={styles.dateTimeRow}>
          <Text
            variant='bodyLarge'
            onPress={() => setVisibleDatePicker(true)}
            style={{ color: theme.colors.primary }}
            disabled={isLoading}
          >
            {startDateTime.format('DD/MM/YYYY')}
          </Text>

          <Text
            variant='bodyLarge'
            onPress={() => setVisibleTimePicker(true)}
            style={{ color: theme.colors.primary }}
            disabled={isLoading}
          >
            {startDateTime.format('HH:mm')}
          </Text>
        </SurfaceCard>

        <SurfaceCard>
          <StudentVisitPicker
            students={initialData?.groupStudents ?? []}
            visitStatus={visitStatus}
            setVisitStatus={setVisitStatus}
            disabled={isLoading}
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
