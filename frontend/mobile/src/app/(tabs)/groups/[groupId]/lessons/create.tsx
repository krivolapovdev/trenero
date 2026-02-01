import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import { api } from '@/src/api';
import type { components } from '@/src/api/generated/openapi';
import {
  LessonForm,
  type LessonFormValues
} from '@/src/components/Form/LessonForm';
import { useCustomAsyncCallback } from '@/src/hooks/useCustomAsyncCallback';
import { useGroupsStore } from '@/src/stores/groupsStore';
import { useStudentsStore } from '@/src/stores/studentsStore';
import type { ApiError } from '@/src/types/error';

type CreateLessonRequest = components['schemas']['CreateLessonRequest'];

export default function CreateLessonScreen() {
  const router = useRouter();
  const { t } = useTranslation();
  const { groupId } = useLocalSearchParams<{ groupId: string }>();

  const removeGroup = useGroupsStore(state => state.removeGroup);
  const refreshStudents = useStudentsStore(state => state.refreshStudents);
  const isRefreshing = useStudentsStore(state => state.isRefreshing);
  const allGroups = useGroupsStore(state => state.allGroups);
  const groupStudents = allGroups.find(
    group => group.id === groupId
  )?.groupStudents;

  const { execute: createLesson, loading: createLessonLoading } =
    useCustomAsyncCallback((request: CreateLessonRequest) =>
      api.POST('/api/v1/lessons', {
        body: request
      })
    );

  const handleSubmit = async (values: LessonFormValues) => {
    if (createLessonLoading) {
      return;
    }

    const request: CreateLessonRequest = {
      groupId,
      ...values
    };

    try {
      await createLesson(request);
      await refreshStudents();
      removeGroup(groupId);
      router.back();
    } catch (err) {
      const errorData = err as ApiError;
      Alert.alert(t('error'), errorData.detail);
    }
  };

  return (
    <LessonForm
      title={t('addLesson')}
      initialData={{
        groupStudents
      }}
      onSubmit={handleSubmit}
      onBack={router.back}
      mutationLoading={createLessonLoading || isRefreshing}
    />
  );
}
