import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import { api } from '@/src/api';
import {
  LessonForm,
  type LessonFormValues
} from '@/src/components/Form/LessonForm';

export default function CreateLessonScreen() {
  const router = useRouter();
  const { t } = useTranslation();
  const { groupId } = useLocalSearchParams<{ groupId: string }>();

  const { data: groupStudents, isLoading: groupStudentsLoading } = api.useQuery(
    'get',
    `/api/v1/groups/{groupId}/students`,
    {
      params: {
        path: {
          groupId
        }
      }
    }
  );

  const { mutate: createLesson, isPending: createLessonPending } =
    api.useMutation('post', '/api/v1/lessons', {
      onSuccess: router.back,
      onError: error => Alert.alert(t('error'), error)
    });

  const handleSubmit = (values: LessonFormValues) => {
    createLesson({
      body: {
        ...values
      }
    });
  };

  return (
    <LessonForm
      title={t('addLesson')}
      initialData={{
        lesson: {
          groupStudents
        }
      }}
      onSubmit={handleSubmit}
      onBack={router.back}
      queryLoading={groupStudentsLoading}
      mutationLoading={createLessonPending}
    />
  );
}
