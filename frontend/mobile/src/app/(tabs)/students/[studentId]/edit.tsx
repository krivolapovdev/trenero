import type { Reference } from '@apollo/client';
import { useMutation, useQuery } from '@apollo/client/react';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import {
  StudentForm,
  type StudentFormValues
} from '@/src/components/StudentForm';
import { graphql } from '@/src/graphql/__generated__';
import type { CreateStudentInput } from '@/src/graphql/__generated__/graphql';
import { GET_STUDENT } from '@/src/graphql/queries';

const EDIT_STUDENT = graphql(`
  mutation EditStudent($id: UUID!, $input: CreateStudentInput!) {
    editStudent(id: $id, input: $input) {
      ...StudentFields
      group {
        id
        students {
          id
        }
      }
    }
  }
`);

export default function EditStudentScreen() {
  const router = useRouter();
  const { t } = useTranslation();
  const { studentId } = useLocalSearchParams<{ studentId: string }>();

  const { data } = useQuery(GET_STUDENT, { variables: { id: studentId } });

  const [editStudent, { loading }] = useMutation(EDIT_STUDENT, {
    update(cache, { data }) {
      const updatedStudent = data?.editStudent;

      if (!updatedStudent) {
        return;
      }

      const identify = cache.identify(updatedStudent);

      if (!identify) {
        return;
      }

      cache.modify({
        fields: {
          students: (existingRefs: readonly Reference[] = []) =>
            existingRefs.map(ref =>
              ref.__ref === identify ? { __ref: identify } : ref
            )
        }
      });
    },

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
