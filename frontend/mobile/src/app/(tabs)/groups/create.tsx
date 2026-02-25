import { useRouter } from 'expo-router';
import { useEffect } from 'react';
import { useAsyncCallback } from 'react-async-hook';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import type { components } from '@/src/api/generated/openapi';
import { createGroup } from '@/src/api/services/group/groupService';
import {
  GroupForm,
  type GroupFormValues
} from '@/src/components/Form/GroupForm';
import { extractErrorMessage } from '@/src/helpers/apiError';

type CreateGroupRequest = components['schemas']['CreateGroupRequest'];

export default function CreateGroupScreen() {
  const { t } = useTranslation();
  const router = useRouter();

  const {
    execute: executeCreateGroup,
    loading: isCreatingGroup,
    error
  } = useAsyncCallback(createGroup);

  const handleSubmit = async (values: GroupFormValues) => {
    if (isCreatingGroup) {
      return;
    }

    const request: CreateGroupRequest = {
      ...values
    };

    const data = await executeCreateGroup(request);

    router.replace(`/(tabs)/groups/${data.id}`);
  };

  useEffect(() => {
    if (error) {
      Alert.alert(t('error'), extractErrorMessage(error));
    }
  }, [error, t]);

  return (
    <GroupForm
      title={t('addGroup')}
      onSubmit={handleSubmit}
      onBack={router.back}
      mutationLoading={isCreatingGroup}
    />
  );
}
