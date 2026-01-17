import { useMutation, useQuery } from '@apollo/client/react';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import {
  LessonForm,
  type LessonFormValues
} from '@/src/components/Form/LessonForm';
import { graphql } from '@/src/graphql/__generated__';
import { GET_GROUP, GET_STUDENTS } from '@/src/graphql/queries';

const CREATE_LESSON = graphql(`
    mutation CreateLesson($input: CreateLessonInput!) {
        createLesson(input: $input) {
            ...LessonDetailsFields
        }
    }
`);

export default function CreateLessonScreen() {
  const router = useRouter();
  const { t } = useTranslation();
  const { groupId } = useLocalSearchParams<{ groupId: string }>();

  const { data } = useQuery(GET_GROUP, {
    variables: { id: groupId },
    fetchPolicy: 'cache-first'
  });

  const [createLesson, { loading }] = useMutation(CREATE_LESSON, {
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

  const handleSubmit = (values: LessonFormValues) => {
    void createLesson({
      variables: {
        input: { groupId, ...values }
      }
    });
  };

  return (
    <LessonForm
      title={t('addLesson')}
      initialData={{
        group: data?.group ?? undefined
      }}
      onSubmit={handleSubmit}
      onBack={router.back}
      queryLoading={loading}
    />
  );
}
