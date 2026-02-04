import { useRouter } from 'expo-router';
import { useEffect } from 'react';
import { useAsyncCallback } from 'react-async-hook';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import type { components } from '@/src/api/generated/openapi';
import { studentService } from '@/src/api/services/student/studentService';
import {
  StudentForm,
  type StudentFormValues
} from '@/src/components/Form/StudentForm';
import { useGroupsStore } from '@/src/stores/groupsStore';

type CreateStudentRequest = components['schemas']['CreateStudentRequest'];

export default function CreateStudentScreen() {
  const { t } = useTranslation();
  const router = useRouter();

  const allGroups = useGroupsStore(state => state.allGroups);
  const updateGroup = useGroupsStore(state => state.updateGroup);

  const {
    execute: createStudent,
    loading: createStudentLoading,
    error
  } = useAsyncCallback(studentService.create);

  const handleSubmit = async (values: StudentFormValues) => {
    if (createStudentLoading) {
      return;
    }

    const request: CreateStudentRequest = {
      ...values
    };

    const data = await createStudent(request);

    if (values.groupId) {
      const targetGroup = allGroups[values.groupId];

      if (targetGroup) {
        updateGroup(values.groupId, {
          groupStudents: [...targetGroup.groupStudents, data]
        });
      }
    }

    router.replace(`/(tabs)/students/${data.id}`);
  };

  useEffect(() => {
    if (error) {
      Alert.alert(t('error'), error.message);
    }
  }, [error, t]);

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
