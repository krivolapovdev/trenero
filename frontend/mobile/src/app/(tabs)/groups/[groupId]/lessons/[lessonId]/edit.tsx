import { useMutation, useQuery } from '@apollo/client/react';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import {
  LessonForm,
  type LessonFormValues
} from '@/src/components/Form/LessonForm';
import { LoadingSpinner } from '@/src/components/LoadingSpinner';
import { graphql } from '@/src/graphql/__generated__';
import { GET_GROUP, GET_LESSON, GET_STUDENTS } from '@/src/graphql/queries';

const EDIT_LESSON = graphql(`
    mutation EditLesson($id: UUID!, $input: CreateLessonInput!) {
        editLesson(id: $id, input: $input) {
            ...LessonDetailsFields
        }
    }
`);

export default function EditLessonScreen() {
  const router = useRouter();
  const { t } = useTranslation();
  const { groupId, lessonId } = useLocalSearchParams<{
    groupId: string;
    lessonId: string;
  }>();

  const { data, loading: queryLoading } = useQuery(GET_LESSON, {
    variables: { id: lessonId }
  });

  const [editLesson, { loading: mutationLoading }] = useMutation(EDIT_LESSON, {
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
  });

  if (queryLoading) {
    return <LoadingSpinner />;
  }

  const handleSubmit = (values: LessonFormValues) => {
    if (!data?.lesson) {
      return;
    }

    void editLesson({
      variables: {
        id: lessonId,
        input: {
          groupId: data.lesson.group.id,
          ...values
        }
      }
    });
  };

  return (
    <LessonForm
      title={t('editLesson')}
      initialData={data?.lesson}
      availableStudents={data?.lesson?.group?.students || []}
      onSubmit={handleSubmit}
      onBack={() => router.back()}
      loading={queryLoading || mutationLoading}
    />
  );
}
