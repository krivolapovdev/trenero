import dayjs from 'dayjs';
import { memo, useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { RefreshControl, ScrollView, StyleSheet } from 'react-native';
import type { components } from '@/src/api/generated/openapi';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { DateInput } from '@/src/components/DateInput';
import {
  StudentVisitPicker,
  type StudentVisitState
} from '@/src/components/StudentVisitPicker';
import { SurfaceCard } from '@/src/components/SurfaceCard';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import type { VisitStatus, VisitType } from '@/src/types/visit';

export type LessonFormValues = {
  date: string;
  students: {
    studentId: string;
    status: VisitStatus;
    type: VisitType;
  }[];
};

type LessonFormInitialData = {
  lesson?: Partial<components['schemas']['LessonDetailsResponse']>;
  groupStudents?: components['schemas']['StudentResponse'][];
};

type Props = {
  title: string;
  queryLoading?: boolean;
  mutationLoading?: boolean;
  initialData?: LessonFormInitialData | null;
  onSubmit: (values: LessonFormValues) => void;
  onBack: () => void;
};

export const LessonForm = memo(
  ({
    title,
    queryLoading,
    mutationLoading = false,
    initialData,
    onSubmit,
    onBack
  }: Readonly<Props>) => {
    const { t } = useTranslation();
    const theme = useAppTheme();

    const [date, setDate] = useState(dayjs().format('DD.MM.YYYY'));
    const [visitState, setVisitState] = useState<
      Record<string, StudentVisitState>
    >({});

    const isLoading = queryLoading || mutationLoading;

    const handleSubmit = () => {
      if (isLoading) {
        return;
      }

      const students = Object.entries(visitState).map(([studentId, state]) => ({
        studentId,
        status: state.status,
        type: state.type
      }));

      onSubmit({
        date: dayjs(date, 'DD.MM.YYYY').format('YYYY-MM-DD'),
        students
      });
    };

    useEffect(() => {
      if (!initialData) {
        return;
      }

      const { lesson, groupStudents = [] } = initialData;

      if (lesson?.date) {
        setDate(dayjs(lesson.date).format('DD.MM.YYYY'));
      }

      const isEditMode = Boolean(lesson?.id);

      const existingVisits = new Map(
        lesson?.studentVisits?.map(visit => [visit.studentId, visit])
      );

      const baseState: StudentVisitState = isEditMode
        ? { status: 'UNMARKED', type: 'UNMARKED' }
        : { status: 'ABSENT', type: 'REGULAR' };

      const newVisitState = Object.fromEntries(
        groupStudents.map(student => [
          student.id,
          {
            status: existingVisits.get(student.id)?.status ?? baseState.status,
            type: existingVisits.get(student.id)?.type ?? baseState.type
          }
        ])
      );

      setVisitState(newVisitState);
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
          <DateInput
            label={t('date')}
            value={date}
            disabled={isLoading}
            onChange={setDate}
          />

          <SurfaceCard>
            <StudentVisitPicker
              students={initialData?.groupStudents ?? []}
              visitState={visitState}
              setVisitState={setVisitState}
              disabled={isLoading}
            />
          </SurfaceCard>
        </ScrollView>
      </>
    );
  }
);

const styles = StyleSheet.create({
  container: { padding: 16, gap: 16 },
  dateTimeRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between'
  }
});
