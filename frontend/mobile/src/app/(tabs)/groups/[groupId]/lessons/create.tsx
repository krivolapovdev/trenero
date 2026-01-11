import { useMutation, useQuery } from '@apollo/client/react';
import dayjs from 'dayjs';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Alert, ScrollView } from 'react-native';
import { Text } from 'react-native-paper';
import { DatePickerModal, TimePickerModal } from 'react-native-paper-dates';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { StudentAttendancePicker } from '@/src/components/StudentAttendancePicker';
import { SurfaceCard } from '@/src/components/SurfaceCard';
import { graphql } from '@/src/graphql/__generated__';
import type { CreateLessonInput } from '@/src/graphql/__generated__/graphql';
import { GET_GROUP } from '@/src/graphql/queries';
import { useAppTheme } from '@/src/hooks/useAppTheme';

const CREATE_LESSON = graphql(`
    mutation CreateLesson($input: CreateLessonInput!) {
        createLesson(input: $input) {
            ...LessonFields
            group {
                id
                lessons {
                    id
                }
            }
            attendances {
                id
                student {
                    id
                    attendances {
                        id
                    }
                }
            }
        }
    }
`);

export default function CreateLessonScreen() {
  const router = useRouter();
  const theme = useAppTheme();
  const { i18n, t } = useTranslation();
  const { groupId } = useLocalSearchParams<{ groupId: string }>();

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
    onCompleted: () => router.back(),
    onError: err => Alert.alert(t('error'), err.message)
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
        title={t('addLesson')}
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
            students={students}
            attendanceStatus={attendanceStatus}
            setAttendanceStatus={setAttendanceStatus}
          />
        </SurfaceCard>
      </ScrollView>

      <TimePickerModal
        locale={i18n.language}
        label=' '
        visible={visibleTimePicker}
        defaultInputType='keyboard'
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
        startWeekOnMonday={true}
        label=' '
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
