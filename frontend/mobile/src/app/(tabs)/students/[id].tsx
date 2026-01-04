import { useMutation, useQuery } from '@apollo/client/react';
import dayjs from 'dayjs';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useState } from 'react';
import { Alert, RefreshControl, ScrollView } from 'react-native';
import { AttendanceCalendar } from '@/src/components/AttendanceCalendar';
import { CreatePaymentSheet } from '@/src/components/CreatePaymentSheet';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import { StudentItem } from '@/src/components/StudentItem';
import { StudentPaymentsTable } from '@/src/components/StudentPaymentsTable';
import { graphql } from '@/src/graphql/__generated__';
import type { GetStudentQuery } from '@/src/graphql/__generated__/graphql';
import { useAppTheme } from '@/src/hooks/useAppTheme';

const buildSubtitle = (student: NonNullable<GetStudentQuery['student']>) =>
  [
    `Group: ${student.group?.name ?? 'Unassigned'}`,
    student.phone && `Phone: ${student.phone}`,
    student.birthDate &&
      `Birthdate: ${dayjs(student.birthDate).format('DD/MM/YYYY')}`,
    student.note && `Note: ${student.note}`
  ]
    .filter(Boolean)
    .join('\n\n');

const GET_STUDENT = graphql(`
    query GetStudent($id: UUID!) {
        student(id: $id) {
            id
            fullName
            phone
            birthDate
            note
            group {
                id
                name
                defaultPrice
            }
            lastAttendance {
                present
            }
            attendances {
                id
                present
                createdAt
            }
            payments {
                id
                amount
                createdAt
            }
        }
    }
`);

const DELETE_STUDENT = graphql(`
    mutation DeleteStudent($id: UUID!) {
        deleteStudent(id: $id) {
            id
        }
    }
`);

export default function StudentByIdScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const theme = useAppTheme();
  const router = useRouter();
  const [paymentSheetVisible, setPaymentSheetVisible] = useState(false);

  const { data, loading, error, refetch } = useQuery(GET_STUDENT, {
    variables: { id },
    fetchPolicy: 'cache-and-network'
  });

  const [deleteStudent, resultDeleteStudent] = useMutation(DELETE_STUDENT, {
    variables: { id },

    update(cache, { data }) {
      if (!data?.deleteStudent) {
        return;
      }

      cache.evict({ id: cache.identify(data.deleteStudent) });
      cache.gc();
    },

    onCompleted: router.back,

    onError: err => Alert.alert('Error', err.message)
  });

  const handleEditPress = () => {
    console.log('Edit pressed');
  };

  const handleDeletePress = () => {
    Alert.alert(
      'Delete student',
      'Are you sure you want to delete this student?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: () => void deleteStudent()
        }
      ]
    );
  };

  const student = data?.student;

  return (
    <>
      <CustomAppbar
        title='Student'
        mode='small'
        leftActions={[
          {
            icon: 'arrow-left',
            onPress: () => router.back(),
            disabled: resultDeleteStudent.loading
          }
        ]}
        rightActions={[
          {
            icon: 'account-cash',
            onPress: () => setPaymentSheetVisible(true),
            disabled: loading || resultDeleteStudent.loading
          },
          {
            icon: 'account-edit',
            onPress: () => handleEditPress(),
            disabled: loading || resultDeleteStudent.loading
          },
          {
            icon: 'trash-can',
            onPress: () => handleDeletePress(),
            disabled: loading || resultDeleteStudent.loading
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
            refreshing={loading}
            onRefresh={refetch}
          />
        }
        keyboardShouldPersistTaps='handled'
      >
        <OptionalErrorMessage error={error?.message} />

        {student && (
          <>
            <StudentItem
              subtitle={buildSubtitle(student)}
              {...student}
            />

            <CreatePaymentSheet
              visible={paymentSheetVisible}
              onDismiss={() => setPaymentSheetVisible(false)}
              studentId={student.id}
              defaultPrice={student.group?.defaultPrice}
            />

            <StudentPaymentsTable payments={student.payments} />

            <AttendanceCalendar attendances={student.attendances} />
          </>
        )}
      </ScrollView>
    </>
  );
}
