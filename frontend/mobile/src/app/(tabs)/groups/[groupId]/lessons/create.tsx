import { useMutation, useQuery } from '@apollo/client/react';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import {
  LessonForm,
  type LessonFormValues
} from '@/src/components/Form/LessonForm';
import { graphql } from '@/src/graphql/__generated__';
import { GET_GROUP } from '@/src/graphql/queries';

const CREATE_LESSON = graphql(`
    mutation CreateLesson($input: CreateLessonInput!) {
        createLesson(input: $input) {
            ...LessonFields
            group {
                id
                lessons {
                    id
                }
            }
            attendances {
                id
                student {
                    id
                    attendances {
                        id
                    }
                }
            }
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
      availableStudents={data?.group?.students || []}
      onSubmit={handleSubmit}
      onBack={() => router.back()}
      loading={loading}
    />
  );
}
