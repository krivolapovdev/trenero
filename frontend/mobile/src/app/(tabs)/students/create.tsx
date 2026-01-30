import { useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import { api } from '@/src/api';
import type { components } from '@/src/api/generated/openapi';
import {
  StudentForm,
  type StudentFormValues
} from '@/src/components/Form/StudentForm';
import { useCustomAsyncCallback } from '@/src/hooks/useCustomAsyncCallback';
import { useGroupsStore } from '@/src/stores/groupsStore';
import type { ApiError } from '@/src/types/error';

type CreateStudentRequest = components['schemas']['CreateStudentRequest'];

export default function CreateStudentScreen() {
  const { t } = useTranslation();
  const router = useRouter();

  const allGroups = useGroupsStore(state => state.allGroups);
  const updateGroup = useGroupsStore(state => state.updateGroup);

  const { execute: createStudent, loading: createStudentLoading } =
    useCustomAsyncCallback((request: CreateStudentRequest) =>
      api.POST('/api/v1/students', {
        body: request
      })
    );

  const handleSubmit = async (values: StudentFormValues) => {
    if (createStudentLoading) {
      return;
    }

    const request: CreateStudentRequest = {
      ...values
    };

    try {
      const data = await createStudent(request);

      if (values.groupId) {
        const targetGroup = allGroups.find(g => g.id === values.groupId);

        if (targetGroup) {
          updateGroup(values.groupId, {
            groupStudents: [...targetGroup.groupStudents, data]
          });
        }
      }

      router.replace(`/(tabs)/students/${data.id}`);
    } catch (err) {
      const errorData = err as ApiError;
      Alert.alert(t('error'), errorData.detail);
    }
  };

  return (
    <StudentForm
      title={t('addStudent')}
      onSubmit={handleSubmit}
      onBack={router.back}
      mutationLoading={createStudentLoading}
      initialData={{
        allGroups
      }}
    />
  );
}
