import { useLocalSearchParams, useRouter } from 'expo-router';
import { useAsync } from 'react-async-hook';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import * as R from 'remeda';
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

  const { loading: lessonLoading, result } = useAsync(
    () =>
      api.GET('/api/v1/lessons/{lessonId}/details', {
        params: {
          path: {
            lessonId
          }
        }
      }),
    [lessonId]
  );

  const lesson = result?.data;

  const { execute: updateLesson, loading: updateLessonLoading } =
    useCustomAsyncCallback((request: UpdateLessonRequest) =>
      api.PATCH('/api/v1/lessons/{lessonId}', {
        params: {
          path: { lessonId }
        },
        body: request
      })
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

    try {
      await updateLesson(request);
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
