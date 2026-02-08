import { useLocalSearchParams, useRouter } from 'expo-router';
import { useEffect } from 'react';
import { useAsyncCallback } from 'react-async-hook';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import * as R from 'remeda';
import { groupService } from '@/src/api/services/group/groupService';
import {
  GroupForm,
  type GroupFormValues
} from '@/src/components/Form/GroupForm';
import { extractErrorMessage } from '@/src/helpers/apiError';
import { useGroupsStore } from '@/src/stores/groupsStore';
import type { GroupDetails } from '@/src/types/group';

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

  const removeGroup = useGroupsStore(state => state.removeGroup);
  const group = useGroupsStore(
    state => state.allGroups[groupId]
  ) as GroupDetails;

  const {
    execute: updateGroup,
    loading: updateGroupLoading,
    error
  } = useAsyncCallback((body: UpdateGroupRequest) =>
    groupService.update(groupId, body)
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

    await updateGroup(request);

    removeGroup(groupId);

    router.back();
  };

  useEffect(() => {
    if (error) {
      Alert.alert(t('error'), extractErrorMessage(error));
    }
  }, [error, t]);

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
