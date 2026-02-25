import { useLocalSearchParams, useRouter } from 'expo-router';
import { useEffect } from 'react';
import { useAsyncCallback } from 'react-async-hook';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import type { components } from '@/src/api/generated/openapi';
import { createLesson } from '@/src/api/services/lesson/lessonService';
import {
  LessonForm,
  type LessonFormValues
} from '@/src/components/Form/LessonForm';
import { extractErrorMessage } from '@/src/helpers/apiError';
import { useGroupsStore } from '@/src/stores/groupsStore';
import { useStudentsStore } from '@/src/stores/studentsStore';

type CreateLessonRequest = components['schemas']['CreateLessonRequest'];

export default function CreateLessonScreen() {
  const router = useRouter();
  const { t } = useTranslation();
  const { groupId } = useLocalSearchParams<{ groupId: string }>();

  const removeGroup = useGroupsStore(state => state.removeGroup);
  const refreshStudents = useStudentsStore(state => state.refreshStudents);
  const isRefreshing = useStudentsStore(state => state.isRefreshing);
  const groupStudents = useGroupsStore(
    state => state.allGroups[groupId]?.groupStudents
  );
  const allStudents = useStudentsStore(state => state.allStudents);

  const {
    execute: executeCreateLesson,
    loading: isCreatingLesson,
    error
  } = useAsyncCallback(createLesson);

  const handleSubmit = async (values: LessonFormValues) => {
    if (isCreatingLesson) {
      return;
    }

    const request: CreateLessonRequest = {
      groupId,
      ...values
    };

    await executeCreateLesson(request);

    await refreshStudents();

    removeGroup(groupId);

    router.back();
  };

  useEffect(() => {
    if (error) {
      Alert.alert(t('error'), extractErrorMessage(error));
    }
  }, [error, t]);

  return (
    <LessonForm
      title={t('addLesson')}
      initialData={{
        groupStudents,
        allStudents
      }}
      onSubmit={handleSubmit}
      onBack={router.back}
      mutationLoading={isCreatingLesson || isRefreshing}
    />
  );
}
