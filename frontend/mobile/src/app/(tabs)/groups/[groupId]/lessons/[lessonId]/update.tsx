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
  const { lessonId } = useLocalSearchParams<{
    groupId: string;
    lessonId: string;
  }>();

  const { data: lesson, isPending: lessonLoading } = api.useQuery(
    'get',
    '/api/v1/lessons/{lessonId}/update',
    {
      params: {
        path: {
          lessonId
        }
      }
    }
  );

  const { mutate: updateLesson, isPending: updateLessonPending } =
    api.useMutation('patch', '/api/v1/lessons/{lessonId}', {
      onSuccess: router.back,
      onError: err => Alert.alert(t('error'), err)
    });

  const handleSubmit = (values: LessonFormValues) => {
    if (!lesson || lessonLoading || updateLessonPending) {
      return;
    }

    const request: components['schemas']['UpdateLessonRequest'] = {};

    if (values.startDateTime !== lesson.startDateTime) {
      request.startDateTime = values.startDateTime;
    }

    const currentStudents = lesson.studentVisits.map(visit => ({
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

  return (
    <LessonForm
      title={t('editLesson')}
      initialData={{
        lesson
      }}
      queryLoading={lessonLoading}
      mutationLoading={updateLessonPending}
      onBack={router.back}
      onSubmit={handleSubmit}
    />
  );
}
