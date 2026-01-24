import { useQueries } from '@tanstack/react-query';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import * as R from 'remeda';
import { api } from '@/src/api';
import type { components } from '@/src/api/generated/openapi';
import {
  LessonForm,
  type LessonFormValues
} from '@/src/components/Form/LessonForm';

export default function UpdateLessonScreen() {
  const router = useRouter();
  const { t } = useTranslation();
  const { groupId, lessonId } = useLocalSearchParams<{
    groupId: string;
    lessonId: string;
  }>();

  const queries = useQueries({
    queries: [
      api.queryOptions('get', '/api/v1/lessons/{lessonId}', {
        params: { path: { lessonId } }
      }),

      api.queryOptions('get', '/api/v1/lessons/{lessonId}/visits', {
        params: { path: { lessonId } }
      }),

      api.queryOptions('get', '/api/v1/groups/{groupId}/students', {
        params: { path: { groupId } }
      })
    ]
  });

  const lesson = queries[0]?.data;
  const visits = queries[1]?.data ?? [];
  const groupStudents = queries[2]?.data ?? [];

  const { mutate: updateLesson, isPending: updateLessonPending } =
    api.useMutation('patch', '/api/v1/lessons/{lessonId}', {
      onSuccess: router.back,
      onError: err => Alert.alert(t('error'), err)
    });

  const handleSubmit = (values: LessonFormValues) => {
    if (!lesson || !visits || updateLessonPending) {
      return;
    }

    const request: components['schemas']['UpdateLessonRequest'] = {};

    if (values.startDateTime !== lesson.startDateTime) {
      request.startDateTime = values.startDateTime;
    }

    const currentStudents = visits.map(visit => ({
      studentId: visit.studentId,
      present: visit.present
    }));

    if (!R.isDeepEqual(currentStudents, values.students)) {
      request.students = values.students;
    }

    if (R.isEmpty(request)) {
      router.back();
      return;
    }

    updateLesson({
      params: {
        path: {
          lessonId
        }
      },
      body: request
    });
  };

  const initialData = {
    lesson,
    visits,
    groupStudents
  };

  return (
    <LessonForm
      title={t('editLesson')}
      initialData={initialData}
      queryLoading={queries.some(q => q.isFetching)}
      mutationLoading={updateLessonPending}
      onBack={router.back}
      onSubmit={handleSubmit}
    />
  );
}
