import { useQueryClient } from '@tanstack/react-query';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import * as R from 'remeda';
import { api } from '@/src/api';
import type { components } from '@/src/api/generated/openapi';
import {
  GroupForm,
  type GroupFormValues
} from '@/src/components/Form/GroupForm';

export default function UpdateGroupScreen() {
  const router = useRouter();
  const { t } = useTranslation();
  const { groupId } = useLocalSearchParams<{ groupId: string }>();
  const queryClient = useQueryClient();

  const { data: group, isPending: groupPending } = api.useQuery(
    'get',
    '/api/v1/groups/{groupId}/update',
    {
      params: {
        path: {
          groupId
        }
      }
    }
  );

  const { mutate: updateGroup, isPending: mutationPending } = api.useMutation(
    'patch',
    '/api/v1/groups/{groupId}',
    {
      onSuccess: async _data => {
        await queryClient.invalidateQueries(
          api.queryOptions('get', '/api/v1/groups/{groupId}/details', {
            params: { path: { groupId } }
          })
        );

        await queryClient.invalidateQueries(
          api.queryOptions('get', '/api/v1/groups/{groupId}/update', {
            params: { path: { groupId } }
          })
        );

        router.back();
      },

      onError: err => Alert.alert('Error', err)
    }
  );

  const handleSubmit = (values: GroupFormValues) => {
    if (!group || groupPending || mutationPending) {
      return;
    }

    const request: components['schemas']['UpdateGroupRequest'] = {};

    if (values.name !== group.name) {
      request.name = values.name;
    }

    if (values.defaultPrice !== group.defaultPrice) {
      request.defaultPrice = values.defaultPrice;
    }

    if (values.note !== group.note) {
      request.note = values.note;
    }

    const currentStudentIds = group.groupStudents.map(student => student.id);

    if (!R.isDeepEqual(currentStudentIds, values.studentIds)) {
      request.studentIds = values.studentIds;
    }

    if (R.isEmpty(request)) {
      router.back();
      return;
    }

    updateGroup({
      params: {
        path: {
          groupId
        }
      },
      body: request
    });
  };

  return (
    <GroupForm
      title={t('editGroup')}
      initialData={{
        group
      }}
      queryLoading={groupPending}
      mutationLoading={mutationPending}
      onBack={router.back}
      onSubmit={handleSubmit}
    />
  );
}
