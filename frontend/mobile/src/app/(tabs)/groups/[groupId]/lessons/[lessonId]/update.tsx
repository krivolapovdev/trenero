import { useLocalSearchParams, useRouter } from 'expo-router';
import { useEffect } from 'react';
import { useAsync, useAsyncCallback } from 'react-async-hook';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import * as R from 'remeda';
import type { components } from '@/src/api/generated/openapi';
import { lessonService } from '@/src/api/services/lesson/lessonService';
import {
  LessonForm,
  type LessonFormValues
} from '@/src/components/Form/LessonForm';
import { useGroupsStore } from '@/src/stores/groupsStore';
import { useStudentsStore } from '@/src/stores/studentsStore';

type UpdateLessonRequest = components['schemas']['UpdateLessonRequest'];

export default function UpdateLessonScreen() {
  const router = useRouter();
  const { t } = useTranslation();
  const { groupId, lessonId } = useLocalSearchParams<{
    groupId: string;
    lessonId: string;
  }>();

  const removeGroup = useGroupsStore(state => state.removeGroup);
  const refreshStudents = useStudentsStore(state => state.refreshStudents);
  const isRefreshing = useStudentsStore(state => state.isRefreshing);
  const allGroups = useGroupsStore(state => state.allGroups);
  const groupStudents = allGroups.find(
    group => group.id === groupId
  )?.groupStudents;

  const {
    loading: lessonLoading,
    result: lesson,
    error: fetchError
  } = useAsync(() => lessonService.getDetails(lessonId), [lessonId]);

  const {
    execute: updateLesson,
    loading: updateLessonLoading,
    error: updateError
  } = useAsyncCallback((body: UpdateLessonRequest) =>
    lessonService.update(lessonId, body)
  );

  const handleSubmit = async (values: LessonFormValues) => {
    if (!lesson || lessonLoading || updateLessonLoading) {
      return;
    }

    const request: UpdateLessonRequest = {};

    if (values.startDateTime !== lesson.startDateTime) {
      request.startDateTime = values.startDateTime;
    }

    const currentStudents = lesson.studentVisits.map(visit => ({
      studentId: visit.studentId,
      status: visit.status
    }));

    if (!R.isDeepEqual(currentStudents, values.students)) {
      request.students = values.students;
    }

    if (R.isEmpty(request)) {
      router.back();
      return;
    }

    await updateLesson(request);

    await refreshStudents();

    removeGroup(groupId);

    router.back();
  };

  useEffect(() => {
    const error = fetchError || updateError;

    if (error) {
      Alert.alert(t('error'), error.message);
    }
  }, [updateError, t, fetchError]);

  return (
    <LessonForm
      title={t('editLesson')}
      initialData={{
        lesson,
        groupStudents
      }}
      queryLoading={lessonLoading}
      mutationLoading={updateLessonLoading || isRefreshing}
      onBack={router.back}
      onSubmit={handleSubmit}
    />
  );
}
