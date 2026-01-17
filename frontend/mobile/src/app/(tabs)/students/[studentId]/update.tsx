import { useMutation, useQuery } from '@apollo/client/react';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import * as R from 'remeda';
import {
  StudentForm,
  type StudentFormValues
} from '@/src/components/Form/StudentForm';
import { graphql } from '@/src/graphql/__generated__';
import type { UpdateStudentInput } from '@/src/graphql/__generated__/graphql';
import { GET_GROUPS, GET_STUDENT, GET_STUDENTS } from '@/src/graphql/queries';

const UPDATE_STUDENT = graphql(`
    mutation EditStudent($id: UUID!, $input: UpdateStudentInput!) {
        updateStudent(id: $id, input: $input) {
            ...StudentDetailsFields
        }
    }
`);

export default function UpdateStudentScreen() {
  const router = useRouter();
  const { t } = useTranslation();
  const { studentId } = useLocalSearchParams<{ studentId: string }>();

  const { data, loading: queryLoading } = useQuery(GET_STUDENT, {
    variables: { id: studentId },
    fetchPolicy: 'cache-first'
  });

  const [updateStudent, { loading: mutationLoading }] = useMutation(
    UPDATE_STUDENT,
    {
      refetchQueries: [GET_GROUPS, GET_STUDENTS],

      awaitRefetchQueries: true,

      onCompleted: () => router.back(),

      onError: err => Alert.alert(t('error'), err.message)
    }
  );

  const handleSubmit = (values: StudentFormValues) => {
    const student = data?.student;

    if (!student || queryLoading || mutationLoading) {
      return;
    }

    const input: UpdateStudentInput = {};

    if (values.fullName !== student.fullName) {
      input.fullName = values.fullName;
    }

    if (values.phone !== student.phone) {
      input.phone = values.phone;
    }

    if (values.note !== student.note) {
      input.note = values.note;
    }

    if (values.birthdate !== student.birthdate) {
      input.birthdate = values.birthdate;
    }

    if (values.groupId !== (student.group?.id ?? null)) {
      input.groupId = values.groupId;
    }

    if (R.isEmpty(input)) {
      router.back();
      return;
    }

    void updateStudent({
      variables: {
        id: studentId,
        input
      }
    });
  };

  const initialData = useMemo(() => data?.student, [data?.student]);

  return (
    <StudentForm
      title={t('editStudent')}
      initialData={initialData}
      queryLoading={queryLoading}
      mutationLoading={mutationLoading}
      onBack={router.back}
      onSubmit={handleSubmit}
    />
  );
}
