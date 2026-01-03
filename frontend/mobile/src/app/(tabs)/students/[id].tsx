import { useMutation, useQuery } from '@apollo/client/react';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { Alert, RefreshControl, ScrollView } from 'react-native';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import { StudentItem } from '@/src/components/StudentItem';
import { graphql } from '@/src/graphql/__generated__';
import { GET_STUDENTS } from '@/src/graphql/queries';
import { useAppTheme } from '@/src/hooks/useAppTheme';

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

  const { data, loading, error, refetch } = useQuery(GET_STUDENT, {
    variables: { id },
    fetchPolicy: 'cache-and-network'
  });

  const [deleteStudent, resultDeleteStudent] = useMutation(DELETE_STUDENT, {
    update(cache, { data }) {
      const deletedStudent = data?.deleteStudent;

      const existingData = cache.readQuery({ query: GET_STUDENTS });

      if (!deletedStudent || !existingData) {
        return;
      }

      cache.writeQuery({
        query: GET_STUDENTS,
        data: {
          ...existingData,
          students: existingData.students.filter(
            s => s.id !== deletedStudent.id
          )
        }
      });
    },

    onCompleted: () => {
      router.back();
    },

    onError: err => {
      Alert.alert('Error', err.message);
    }
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
          onPress: () => {
            void deleteStudent({ variables: { id } });
          }
        }
      ]
    );
  };

  const student = data?.student;

  return (
    <>
      <CustomAppbar
        title='Student'
        leftActions={[
          {
            icon: 'arrow-left',
            onPress: () => router.back(),
            disabled: resultDeleteStudent.loading
          }
        ]}
        rightActions={[
          {
            icon: 'account-edit',
            onPress: () => handleEditPress(),
            disabled: resultDeleteStudent.loading
          },
          {
            icon: 'trash-can',
            onPress: () => handleDeletePress(),
            disabled: resultDeleteStudent.loading
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
      >
        <OptionalErrorMessage error={error?.message} />

        {student && (
          <StudentItem
            id={student.id}
            fullName={student.fullName}
            group={student.group}
            lastAttendance={student.lastAttendance}
          />
        )}
      </ScrollView>
    </>
  );
}
