import { useQueryClient } from '@tanstack/react-query';
import { useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import { api } from '@/src/api';
import {
  GroupForm,
  type GroupFormValues
} from '@/src/components/Form/GroupForm';

export default function CreateGroupScreen() {
  const { t } = useTranslation();
  const router = useRouter();
  const queryClient = useQueryClient();

  const { mutate: createGroup, isPending: mutationPending } = api.useMutation(
    'post',
    '/api/v1/groups',
    {
      onSuccess: data => {
        router.replace(`/(tabs)/groups/${data.id}`);

        void queryClient.invalidateQueries(
          api.queryOptions('get', '/api/v1/groups/overview')
        );

        void queryClient.invalidateQueries(
          api.queryOptions('get', '/api/v1/students/overview')
        );
      },

      onError: error => Alert.alert('Error', error)
    }
  );

  const handleSubmit = (values: GroupFormValues) => {
    if (mutationPending) {
      return;
    }

    createGroup({
      body: {
        ...values
      }
    });
  };

  return (
    <GroupForm
      title={t('addGroup')}
      onSubmit={handleSubmit}
      onBack={router.back}
      queryLoading={mutationPending}
    />
  );
}
