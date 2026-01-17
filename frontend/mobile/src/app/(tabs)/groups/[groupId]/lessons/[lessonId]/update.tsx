import { useMutation, useQuery } from '@apollo/client/react';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import * as R from 'remeda';
import {
  LessonForm,
  type LessonFormValues
} from '@/src/components/Form/LessonForm';
import { graphql } from '@/src/graphql/__generated__';
import type { UpdateLessonInput } from '@/src/graphql/__generated__/graphql';
import { GET_GROUP, GET_LESSON, GET_STUDENTS } from '@/src/graphql/queries';

const UPDATE_LESSON = graphql(`
    mutation UpdateLesson($id: UUID!, $input: UpdateLessonInput!) {
        updateLesson(id: $id, input: $input) {
            ...LessonDetailsFields
        }
    }
`);

export default function UpdateLessonScreen() {
  const router = useRouter();
  const { t } = useTranslation();
  const { groupId, lessonId } = useLocalSearchParams<{
    groupId: string;
    lessonId: string;
  }>();

  const { data, loading: queryLoading } = useQuery(GET_LESSON, {
    variables: { id: lessonId }
  });

  const [updateLesson, { loading: mutationLoading }] = useMutation(
    UPDATE_LESSON,
    {
      refetchQueries: [
        {
          query: GET_GROUP,
          variables: { id: groupId }
        },
        GET_STUDENTS
      ],

      awaitRefetchQueries: true,

      onCompleted: () => router.back(),

      onError: err => Alert.alert(t('error'), err.message)
    }
  );

  const handleSubmit = (values: LessonFormValues) => {
    const lesson = data?.lesson;

    if (!lesson || queryLoading || mutationLoading) {
      return;
    }

    const input: UpdateLessonInput = {};

    if (values.startDateTime !== lesson.startDateTime) {
      input.startDateTime = values.startDateTime;
    }

    const currentAttendance = lesson.attendances.map(a => ({
      studentId: a.student.id,
      present: a.present
    }));

    if (!R.isDeepEqual(currentAttendance, values.students)) {
      input.students = values.students;
    }

    if (R.isEmpty(input)) {
      router.back();
      return;
    }

    void updateLesson({
      variables: {
        id: lessonId,
        input: {
          ...values
        }
      }
    });
  };

  const initialData = useMemo(() => data?.lesson, [data?.lesson]);

  return (
    <LessonForm
      title={t('editLesson')}
      initialData={initialData}
      queryLoading={queryLoading}
      mutationLoading={mutationLoading}
      onBack={router.back}
      onSubmit={handleSubmit}
    />
  );
}
