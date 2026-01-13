import { useMutation, useQuery } from '@apollo/client/react';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import {
  GroupForm,
  type GroupFormValues
} from '@/src/components/Form/GroupForm';
import { graphql } from '@/src/graphql/__generated__';
import { GET_GROUP, GET_GROUPS, GET_STUDENTS } from '@/src/graphql/queries';

const EDIT_GROUP = graphql(`
    mutation EditGroup($id: UUID!, $input: CreateGroupInput!) {
        editGroup(id: $id, input: $input) {
            ...GroupDetailsFields
        }
    }
`);

export default function EditGroupScreen() {
  const router = useRouter();
  const { t } = useTranslation();
  const { groupId } = useLocalSearchParams<{ groupId: string }>();

  const { data } = useQuery(GET_GROUP, {
    variables: { id: groupId },
    fetchPolicy: 'cache-first'
  });

  const [editGroup, { loading }] = useMutation(EDIT_GROUP, {
    refetchQueries: [GET_STUDENTS, GET_GROUPS],

    awaitRefetchQueries: true,

    onCompleted: () => router.back(),

    onError: err => Alert.alert('Error', err.message)
  });

  const handleSubmit = (values: GroupFormValues) => {
    void editGroup({
      variables: {
        id: groupId,
        input: { ...values }
      }
    });
  };

  if (!data) {
    return null;
  }

  return (
    <GroupForm
      title={t('editGroup')}
      initialData={data.group}
      loading={loading}
      onBack={() => router.back()}
      onSubmit={handleSubmit}
    />
  );
}
