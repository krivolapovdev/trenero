import { useMutation, useQuery } from '@apollo/client/react';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import {
  StudentForm,
  type StudentFormValues
} from '@/src/components/Form/StudentForm';
import { graphql } from '@/src/graphql/__generated__';
import type { CreateStudentInput } from '@/src/graphql/__generated__/graphql';
import { GET_GROUPS, GET_STUDENT, GET_STUDENTS } from '@/src/graphql/queries';

const EDIT_STUDENT = graphql(`
    mutation EditStudent($id: UUID!, $input: CreateStudentInput!) {
        editStudent(id: $id, input: $input) {
            ...StudentDetailsFields
        }
    }
`);

export default function EditStudentScreen() {
  const router = useRouter();
  const { t } = useTranslation();
  const { studentId } = useLocalSearchParams<{ studentId: string }>();

  const { data } = useQuery(GET_STUDENT, {
    variables: { id: studentId },
    fetchPolicy: 'cache-first'
  });

  const [editStudent, { loading }] = useMutation(EDIT_STUDENT, {
    refetchQueries: [GET_GROUPS, GET_STUDENTS],

    awaitRefetchQueries: true,

    onCompleted: () => router.back(),

    onError: err => Alert.alert(t('error'), err.message)
  });

  const handleSubmit = ({
    fullName,
    phone,
    note,
    groupId,
    birthdate
  }: StudentFormValues) => {
    if (loading) {
      return;
    }

    const input: CreateStudentInput = {
      fullName,
      phone,
      note,
      birthdate,
      groupId
    };

    void editStudent({ variables: { id: studentId, input } });
  };

  if (!data?.student) {
    return null;
  }

  return (
    <StudentForm
      title={t('editStudent')}
      initialData={data.student}
      loading={loading}
      onBack={() => router.back()}
      onSubmit={handleSubmit}
    />
  );
}
