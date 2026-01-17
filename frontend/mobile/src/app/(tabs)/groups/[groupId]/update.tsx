import { useMutation, useQuery } from '@apollo/client/react';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import * as R from 'remeda';
import {
  GroupForm,
  type GroupFormValues
} from '@/src/components/Form/GroupForm';
import { graphql } from '@/src/graphql/__generated__';
import type { UpdateGroupInput } from '@/src/graphql/__generated__/graphql';
import { GET_GROUP, GET_GROUPS, GET_STUDENTS } from '@/src/graphql/queries';

const UPDATE_GROUP = graphql(`
    mutation UpdateGroup($id: UUID!, $input: UpdateGroupInput!) {
        updateGroup(id: $id, input: $input) {
            ...GroupDetailsFields
        }
    }
`);

export default function UpdateGroupScreen() {
  const router = useRouter();
  const { t } = useTranslation();
  const { groupId } = useLocalSearchParams<{ groupId: string }>();

  const { data, loading: queryLoading } = useQuery(GET_GROUP, {
    variables: { id: groupId },
    fetchPolicy: 'cache-first'
  });

  const [updateGroup, { loading: mutationLoading }] = useMutation(
    UPDATE_GROUP,
    {
      refetchQueries: [GET_STUDENTS, GET_GROUPS],

      awaitRefetchQueries: true,

      onCompleted: () => router.back(),

      onError: err => Alert.alert('Error', err.message)
    }
  );

  const handleSubmit = (values: GroupFormValues) => {
    const group = data?.group;

    if (!group || queryLoading || mutationLoading) {
      return;
    }

    const input: UpdateGroupInput = {};

    if (values.name !== group.name) {
      input.name = values.name;
    }

    if (values.defaultPrice !== group.defaultPrice) {
      input.defaultPrice = values.defaultPrice;
    }

    if (values.note !== group.note) {
      input.note = values.note;
    }

    const currentStudentIds = group.students?.map(student => student.id) || [];

    if (!R.isDeepEqual(currentStudentIds, values.studentIds)) {
      input.studentIds = values.studentIds;
    }

    if (R.isEmpty(input)) {
      router.back();
      return;
    }

    void updateGroup({
      variables: {
        id: groupId,
        input
      }
    });
  };

  const initialData = useMemo(() => data?.group, [data?.group]);

  return (
    <GroupForm
      title={t('editGroup')}
      initialData={initialData}
      queryLoading={queryLoading}
      mutationLoading={mutationLoading}
      onBack={router.back}
      onSubmit={handleSubmit}
    />
  );
}
