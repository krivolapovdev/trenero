import { useMutation } from '@apollo/client/react';
import { useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import {
  GroupForm,
  type GroupFormValues
} from '@/src/components/Form/GroupForm';
import { graphql } from '@/src/graphql/__generated__';
import type { CreateGroupInput } from '@/src/graphql/__generated__/graphql';
import { GET_GROUPS, GET_STUDENTS } from '@/src/graphql/queries';

const CREATE_GROUP = graphql(`
    mutation CreateGroup($input: CreateGroupInput!) {
        createGroup(input: $input) {
            ...GroupDetailsFields
        }
    }
`);

export default function CreateGroupScreen() {
  const { t } = useTranslation();
  const router = useRouter();

  const [createGroup, { loading }] = useMutation(CREATE_GROUP, {
    refetchQueries: [GET_GROUPS, GET_STUDENTS],

    awaitRefetchQueries: true,

    onCompleted: data =>
      router.replace(`/(tabs)/groups/${data.createGroup.id}`),

    onError: err => Alert.alert('Error', err.message)
  });

  const handleSubmit = ({
    name,
    defaultPrice,
    note,
    studentIds
  }: GroupFormValues) => {
    if (loading) {
      return;
    }

    const input: CreateGroupInput = {
      name,
      defaultPrice,
      note,
      studentIds
    };

    void createGroup({ variables: { input } });
  };

  return (
    <GroupForm
      title={t('addGroup')}
      onSubmit={handleSubmit}
      onBack={() => router.back()}
      queryLoading={loading}
    />
  );
}
