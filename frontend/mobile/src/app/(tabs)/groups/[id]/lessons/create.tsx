import { useMutation, useQuery } from '@apollo/client/react';
import dayjs from 'dayjs';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useCallback, useEffect, useMemo, useState } from 'react';
import { Alert, ScrollView, View } from 'react-native';
import { Button, Switch, Text } from 'react-native-paper';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { SurfaceCard } from '@/src/components/SurfaceCard';
import { graphql } from '@/src/graphql/__generated__';
import type { CreateLessonInput } from '@/src/graphql/__generated__/graphql';
import { GET_GROUP } from '@/src/graphql/queries';
import { useAppTheme } from '@/src/hooks/useAppTheme';

const CREATE_LESSON = graphql(`
    mutation CreateLesson($input: CreateLessonInput!) {
        createLesson(input: $input) {
            id
            groupId
            startDateTime
        }
    }
`);

export default function CreateLessonScreen() {
  const router = useRouter();
  const theme = useAppTheme();
  const { id: groupId } = useLocalSearchParams<{ id: string }>();
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

      cache.modify({
        id: cache.identify({ __typename: 'Group', id: newLesson.groupId }),
        fields: {
          lessons(existingLessons = []) {
            return [...existingLessons, newLesson];
          }
        }
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
      startDateTime: dayjs().toISOString(),
      students
    };

    void createLesson({
      variables: { input }
    });
  };

  const selectAll = useCallback(() => {
    setAttendanceStatus(
      Object.fromEntries(
        (data?.group?.students || []).map(student => [student.id, true])
      )
    );
  }, [data]);

  const unselectAll = useCallback(() => {
    setAttendanceStatus(
      Object.fromEntries(
        (data?.group?.students || []).map(student => [student.id, false])
      )
    );
  }, [data]);

  const students = useMemo(() => data?.group?.students || [], [data]);
  const anyPresent = Object.values(attendanceStatus).some(Boolean);

  useEffect(() => {
    setAttendanceStatus(
      Object.fromEntries(students.map(student => [student.id, false]))
    );
  }, [students]);

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
        <SurfaceCard>
          <View
            style={{
              flexDirection: 'row',
              alignItems: 'center',
              justifyContent: 'space-between',
              gap: 8,
              marginBottom: 8
            }}
          >
            <Text style={{ fontSize: 16, marginBottom: 8 }}>
              Select Students
            </Text>

            <Button
              mode='text'
              onPress={anyPresent ? unselectAll : selectAll}
            >
              {anyPresent ? 'Unselect All' : 'Select All'}
            </Button>
          </View>

          {students.length === 0 && <Text>No students found</Text>}

          {students.map(student => (
            <View
              key={student.id}
              style={{
                flexDirection: 'row',
                alignItems: 'center',
                justifyContent: 'space-between',
                paddingVertical: 8
              }}
            >
              <Text>{student.fullName}</Text>

              <Switch
                value={attendanceStatus[student.id] ?? false}
                onValueChange={value =>
                  setAttendanceStatus(prev => ({
                    ...prev,
                    [student.id]: value
                  }))
                }
              />
            </View>
          ))}
        </SurfaceCard>
      </ScrollView>
    </>
  );
}
