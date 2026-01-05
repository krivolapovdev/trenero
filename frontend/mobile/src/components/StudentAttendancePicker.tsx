// src/components/StudentSelection.tsx
import {
  type Dispatch,
  memo,
  type SetStateAction,
  useCallback,
  useEffect,
  useMemo
} from 'react';
import { View } from 'react-native';
import { Button, Switch, Text } from 'react-native-paper';
import type { GetGroupQuery } from '@/src/graphql/__generated__/graphql';

type Props = {
  students: NonNullable<GetGroupQuery['group']>['students'];
  attendanceStatus: Record<string, boolean>;
  setAttendanceStatus: Dispatch<SetStateAction<Record<string, boolean>>>;
};

export const StudentAttendancePicker = memo(
  ({ students, attendanceStatus, setAttendanceStatus }: Readonly<Props>) => {
    const anyPresent = useMemo(
      () => Object.values(attendanceStatus).some(Boolean),
      [attendanceStatus]
    );

    const selectAll = useCallback(() => {
      setAttendanceStatus(
        Object.fromEntries(students.map(student => [student.id, true]))
      );
    }, [setAttendanceStatus, students.map]);

    const unselectAll = useCallback(() => {
      setAttendanceStatus(
        Object.fromEntries(students.map(student => [student.id, false]))
      );
    }, [setAttendanceStatus, students.map]);

    useEffect(() => {
      setAttendanceStatus((prev: Record<string, boolean>) => {
        if (Object.keys(prev).length === 0 && students.length > 0) {
          return Object.fromEntries(
            students.map(student => [student.id, false])
          );
        }
        return prev;
      });
    }, [students, setAttendanceStatus]);

    if (students.length === 0) {
      return <Text>No students found</Text>;
    }

    return (
      <View style={{ gap: 8 }}>
        <View
          style={{
            flexDirection: 'row',
            alignItems: 'center',
            justifyContent: 'space-between',
            marginBottom: 8
          }}
        >
          <Text style={{ fontSize: 16 }}>Select Students</Text>

          <Button
            mode='text'
            onPress={anyPresent ? unselectAll : selectAll}
          >
            {anyPresent ? 'Unselect All' : 'Select All'}
          </Button>
        </View>

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
              style={{ padding: 0 }}
              onValueChange={value =>
                setAttendanceStatus(prev => ({ ...prev, [student.id]: value }))
              }
            />
          </View>
        ))}
      </View>
    );
  }
);
