import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import * as R from 'remeda';
import { api } from '@/src/api';
import type { components } from '@/src/api/generated/openapi';
import {
  StudentForm,
  type StudentFormValues
} from '@/src/components/Form/StudentForm';

export default function UpdateStudentScreen() {
  const router = useRouter();
  const { t } = useTranslation();
  const { studentId } = useLocalSearchParams<{ studentId: string }>();

  const { data: student, isFetching: queryFetching } = api.useQuery(
    'get',
    `/api/v1/students/{studentId}`,
    {
      params: { path: { studentId } }
    }
  );

  const { mutate: updateStudent, isPending: updateStudentPending } =
    api.useMutation('patch', `/api/v1/students/{studentId}`, {
      onSuccess: router.back,
      onError: err => Alert.alert(t('error'), err)
    });

  const handleSubmit = (values: StudentFormValues) => {
    if (!student || queryFetching || updateStudentPending) {
      return;
    }

    const request: components['schemas']['UpdateStudentRequest'] = {};

    if (values.fullName !== student.fullName) {
      request.fullName = values.fullName;
    }

    if (values.phone !== student.phone) {
      request.phone = values.phone;
    }

    if (values.note !== student.note) {
      request.note = values.note;
    }

    if (values.birthdate !== student.birthdate) {
      request.birthdate = values.birthdate;
    }

    if (values.groupId !== student.groupId) {
      request.groupId = values.groupId;
    }

    if (R.isEmpty(request)) {
      router.back();
      return;
    }

    updateStudent({
      params: {
        path: {
          studentId
        }
      },
      body: request
    });
  };

  return (
    <StudentForm
      title={t('editStudent')}
      initialData={{
        student
      }}
      queryLoading={queryFetching}
      mutationLoading={updateStudentPending}
      onBack={router.back}
      onSubmit={handleSubmit}
    />
  );
}
