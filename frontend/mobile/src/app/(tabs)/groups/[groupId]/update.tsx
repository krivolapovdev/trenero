import { useQueries } from '@tanstack/react-query';
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

  const queries = useQueries({
    queries: [
      api.queryOptions('get', '/api/v1/groups/{groupId}', {
        params: {
          path: { groupId }
        }
      }),

      api.queryOptions('get', '/api/v1/groups/{groupId}/students', {
        params: {
          path: { groupId }
        }
      }),

      api.queryOptions('get', '/api/v1/groups/{groupId}/lessons', {
        params: {
          path: { groupId }
        }
      }),

      api.queryOptions('get', '/api/v1/students')
    ]
  });

  const queriesLoading = queries.some(q => q.isFetching);

  const group = queries[0]?.data;
  const groupStudents = queries[1].data;
  const groupLessons = queries[2].data;
  const allStudents = queries[3].data;

  const { mutate: updateGroup, isPending: mutationLoading } = api.useMutation(
    'patch',
    '/api/v1/groups/{groupId}',
    {
      onSuccess: router.back,

      onError: err => Alert.alert('Error', err)
    }
  );

  const handleSubmit = (values: GroupFormValues) => {
    if (
      !group ||
      !groupStudents ||
      !groupLessons ||
      queriesLoading ||
      mutationLoading
    ) {
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

    const currentStudentIds = groupStudents.map(student => student.id) ?? [];

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

  const initialData = {
    group,
    groupStudents,
    allStudents
  };

  return (
    <GroupForm
      title={t('editGroup')}
      initialData={initialData}
      queryLoading={queriesLoading}
      mutationLoading={mutationLoading}
      onBack={router.back}
      onSubmit={handleSubmit}
    />
  );
}
