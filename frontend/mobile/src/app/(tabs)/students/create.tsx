import type { Reference } from '@apollo/client';
import { useMutation } from '@apollo/client/react';
import { useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import {
  StudentForm,
  type StudentFormValues
} from '@/src/components/StudentForm';
import { graphql } from '@/src/graphql/__generated__';
import type { CreateStudentInput } from '@/src/graphql/__generated__/graphql';

const CREATE_STUDENT = graphql(`
  mutation CreateStudent($input: CreateStudentInput!) {
    createStudent(input: $input) {
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

export default function CreateStudentScreen() {
  const { t } = useTranslation();
  const router = useRouter();

  const [createStudent, { loading }] = useMutation(CREATE_STUDENT, {
    update(cache, { data }) {
      const newStudent = data?.createStudent;
      if (!newStudent) {
        return;
      }

      const identify = cache.identify(newStudent);
      if (!identify) {
        return;
      }

      cache.modify({
        fields: {
          students: (existingRefs: readonly Reference[] = []) => [
            { __ref: identify },
            ...existingRefs
          ]
        }
      });
    },

    onCompleted: data =>
      router.replace(`/(tabs)/students/${data.createStudent.id}`),
    onError: err => Alert.alert(t('error'), err.message)
  });

  const handleSubmit = (values: StudentFormValues) => {
    if (loading) {
      return;
    }

    const input: CreateStudentInput = {
      fullName: values.fullName,
      phone: values.phone,
      note: values.note,
      birthdate: values.birthdate,
      groupId: values.groupId
    };

    void createStudent({ variables: { input } });
  };

  return (
    <StudentForm
      title={t('addStudent')}
      onSubmit={handleSubmit}
      onBack={() => router.back()}
      loading={loading}
    />
  );
}
