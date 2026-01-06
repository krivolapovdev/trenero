import type { Reference } from '@apollo/client';
import { useMutation, useQuery } from '@apollo/client/react';
import dayjs from 'dayjs';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useMemo, useState } from 'react';
import { Alert, ScrollView } from 'react-native';
import { Text } from 'react-native-paper';
import {
  DatePickerModal,
  registerTranslation,
  ru,
  TimePickerModal
} from 'react-native-paper-dates';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { StudentAttendancePicker } from '@/src/components/StudentAttendancePicker';
import { SurfaceCard } from '@/src/components/SurfaceCard';
import { graphql } from '@/src/graphql/__generated__';
import {
  AttendanceFieldsFragmentDoc,
  type CreateLessonInput,
  LessonFieldsFragmentDoc
} from '@/src/graphql/__generated__/graphql';
import { GET_GROUP } from '@/src/graphql/queries';
import { useAppTheme } from '@/src/hooks/useAppTheme';

registerTranslation('ru', ru);

const CREATE_LESSON = graphql(`
    mutation CreateLesson($input: CreateLessonInput!) {
        createLesson(input: $input) {
            ...LessonFields
        }
    }
`);

export default function CreateLessonScreen() {
  const router = useRouter();
  const theme = useAppTheme();
  const { id: groupId } = useLocalSearchParams<{ id: string }>();

  const [startDateTime, setStartDateTime] = useState(dayjs());
  const [visibleTimePicker, setVisibleTimePicker] = useState(false);
  const [visibleDatePicker, setVisibleDatePicker] = useState(false);

  const [attendanceStatus, setAttendanceStatus] = useState<
    Record<string, boolean>
  >({});

  const { data } = useQuery(GET_GROUP, {
    variables: { id: groupId },
    fetchPolicy: 'cache-first'
  });

  const [createLesson, { loading }] = useMutation(CREATE_LESSON, {
    update(cache, { data }) {
      const newLesson = data?.createLesson;

      if (!newLesson) {
        return;
      }

      const newLessonRef = cache.writeFragment({
        data: newLesson,
        fragment: LessonFieldsFragmentDoc,
        fragmentName: 'LessonFields'
      });

      cache.modify({
        id: cache.identify({ __typename: 'Group', id: newLesson.groupId }),
        fields: {
          lessons: (existingLessons = []) => [...existingLessons, newLessonRef]
        }
      });

      newLesson.attendances.forEach(attendance => {
        const attendanceRef = cache.writeFragment({
          data: attendance,
          fragment: AttendanceFieldsFragmentDoc
        });

        if (!attendanceRef) {
          return;
        }

        cache.modify({
          id: cache.identify({
            __typename: 'Student',
            id: attendance.studentId
          }),
          fields: {
            attendances: (existing: readonly Reference[] = []) => [
              ...existing,
              attendanceRef
            ]
          }
        });
      });
    },

    onCompleted: () => router.back(),

    onError: err => Alert.alert('Error', err.message)
  });

  const handleSubmit = () => {
    const students = Object.entries(attendanceStatus).map(
      ([studentId, present]) => ({
        studentId,
        present
      })
    );

    const input: CreateLessonInput = {
      groupId,
      startDateTime: startDateTime.toISOString(),
      students
    };

    void createLesson({
      variables: { input }
    });
  };

  const students = useMemo(() => data?.group?.students || [], [data]);

  return (
    <>
      <CustomAppbar
        title='Add Lesson'
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
            disabled: loading,
            onPress: handleSubmit
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
      >
        <SurfaceCard
          style={{
            flex: 1,
            flexDirection: 'row',
            alignItems: 'center',
            justifyContent: 'space-between'
          }}
        >
          <Text
            variant={'bodyLarge'}
            onPress={() => setVisibleDatePicker(true)}
            style={{ color: theme.colors.primary }}
          >
            {startDateTime.format('DD/MM/YYYY')}
          </Text>

          <Text
            variant={'bodyLarge'}
            onPress={() => setVisibleTimePicker(true)}
            style={{ color: theme.colors.primary }}
          >
            {startDateTime.format('HH:mm')}
          </Text>
        </SurfaceCard>

        <SurfaceCard>
          <StudentAttendancePicker
            students={students}
            attendanceStatus={attendanceStatus}
            setAttendanceStatus={setAttendanceStatus}
          />
        </SurfaceCard>
      </ScrollView>

      <TimePickerModal
        locale='ru'
        label={' '}
        visible={visibleTimePicker}
        defaultInputType={'keyboard'}
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
        locale='ru'
        startWeekOnMonday={true}
        label={' '}
        mode='single'
        visible={visibleDatePicker}
        onDismiss={() => setVisibleDatePicker(false)}
        date={startDateTime.toDate()}
        validRange={{
          endDate: new Date()
        }}
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
}
