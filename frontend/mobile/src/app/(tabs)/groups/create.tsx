import { useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import { api } from '@/src/api';
import type { components } from '@/src/api/generated/openapi';
import {
  GroupForm,
  type GroupFormValues
} from '@/src/components/Form/GroupForm';
import { useCustomAsyncCallback } from '@/src/hooks/useCustomAsyncCallback';
import type { ApiError } from '@/src/types/error';

type CreateGroupRequest = components['schemas']['CreateGroupRequest'];

export default function CreateGroupScreen() {
  const { t } = useTranslation();
  const router = useRouter();

  const { execute: createGroup, loading: createGroupLoading } =
    useCustomAsyncCallback((body: CreateGroupRequest) =>
      api.POST('/api/v1/groups', { body })
    );

  const handleSubmit = async (values: GroupFormValues) => {
    if (createGroupLoading) {
      return;
    }

    const request: CreateGroupRequest = {
      ...values
    };

    try {
      const data = await createGroup(request);
      router.replace(`/(tabs)/groups/${data.id}`);
    } catch (err) {
      const errorData = err as ApiError;
      Alert.alert(t('error'), errorData.detail);
    }
  };

  return (
    <GroupForm
      title={t('addGroup')}
      onSubmit={handleSubmit}
      onBack={router.back}
      mutationLoading={createGroupLoading}
    />
  );
}
