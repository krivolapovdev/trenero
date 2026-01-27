import { useQueryClient } from '@tanstack/react-query';
import { useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import { api } from '@/src/api';
import type { components } from '@/src/api/generated/openapi';
import {
  StudentForm,
  type StudentFormValues
} from '@/src/components/Form/StudentForm';

export default function CreateStudentScreen() {
  const { t } = useTranslation();
  const router = useRouter();
  const queryClient = useQueryClient();

  const { data: groups, isLoading: groupsLoading } = api.useQuery(
    'get',
    '/api/v1/groups'
  );

  const { mutate: createStudent, isPending: createStudentPending } =
    api.useMutation('post', '/api/v1/students', {
      onSuccess: data => {
        router.replace(`/(tabs)/students/${data.id}`);

        void queryClient.invalidateQueries(
          api.queryOptions('get', '/api/v1/groups/overview')
        );

        void queryClient.invalidateQueries(
          api.queryOptions('get', '/api/v1/students/overview')
        );
      },

      onError: err => Alert.alert(t('error'), err)
    });

  const handleSubmit = (values: StudentFormValues) => {
    if (createStudentPending) {
      return;
    }

    const request: components['schemas']['CreateStudentRequest'] = {
      fullName: values.fullName,
      phone: values.phone,
      note: values.note,
      birthdate: values.birthdate,
      groupId: values.groupId
    };

    createStudent({
      body: request
    });
  };

  const initialData = {
    groups
  };

  return (
    <StudentForm
      title={t('addStudent')}
      onSubmit={handleSubmit}
      onBack={router.back}
      queryLoading={groupsLoading}
      mutationLoading={createStudentPending}
      initialData={initialData}
    />
  );
}
