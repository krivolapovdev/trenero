import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import * as R from 'remeda';
import { api } from '@/src/api';
import {
  GroupForm,
  type GroupFormValues
} from '@/src/components/Form/GroupForm';
import { useCustomAsyncCallback } from '@/src/hooks/useCustomAsyncCallback';
import { useGroupsStore } from '@/src/stores/groupsStore';
import type { ApiError } from '@/src/types/error';

type UpdateGroupRequest = {
  name?: string | null;
  defaultPrice?: number | null;
  note?: string | null;
  studentIds?: string[] | null;
};

export default function UpdateGroupScreen() {
  const router = useRouter();
  const { t } = useTranslation();
  const { groupId } = useLocalSearchParams<{ groupId: string }>();

  const recentGroups = useGroupsStore(state => state.recentGroups);
  const removeGroup = useGroupsStore(state => state.removeGroup);
  const group = recentGroups.find(group => group.id === groupId);

  const { execute: updateGroup, loading: updateGroupLoading } =
    useCustomAsyncCallback((request: UpdateGroupRequest) =>
      api.PATCH('/api/v1/groups/{groupId}', {
        params: {
          path: { groupId }
        },
        body: request
      })
    );

  const handleSubmit = async (values: GroupFormValues) => {
    if (!group || updateGroupLoading) {
      return;
    }

    const request: UpdateGroupRequest = {};

    if (values.name !== group.name) {
      request.name = values.name ?? null;
    }

    if (values.defaultPrice !== group.defaultPrice) {
      request.defaultPrice = values.defaultPrice ?? null;
    }

    if (values.note !== group.note) {
      request.note = values.note ?? null;
    }

    if (R.isEmpty(request)) {
      router.back();
      return;
    }

    try {
      await updateGroup(request);
      removeGroup(groupId);
      router.back();
    } catch (err) {
      const errorData = err as ApiError;
      Alert.alert(t('error'), errorData.detail);
    }
  };

  return (
    <GroupForm
      title={t('editGroup')}
      initialData={{
        group
      }}
      mutationLoading={updateGroupLoading}
      onBack={router.back}
      onSubmit={handleSubmit}
    />
  );
}
