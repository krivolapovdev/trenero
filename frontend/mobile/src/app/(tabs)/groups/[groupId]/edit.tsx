import type { Reference } from '@apollo/client';
import { useMutation, useQuery } from '@apollo/client/react';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import { GroupForm, type GroupFormValues } from '@/src/components/GroupForm';
import { graphql } from '@/src/graphql/__generated__';
import type { CreateGroupInput } from '@/src/graphql/__generated__/graphql';
import { GET_GROUP } from '@/src/graphql/queries';

const EDIT_GROUP = graphql(`
  mutation EditGroup($id: UUID!, $input: CreateGroupInput!) {
    editGroup(id: $id, input: $input) {
      ...GroupFields
        students {
            id
            group {
                id
            }
        }
    }
  }
`);

export default function EditGroupScreen() {
  const router = useRouter();
  const { t } = useTranslation();
  const { groupId } = useLocalSearchParams<{ groupId: string }>();

  const { data } = useQuery(GET_GROUP, { variables: { id: groupId } });

  const [editGroup, { loading }] = useMutation(EDIT_GROUP, {
    update(cache, { data }) {
      const updatedGroup = data?.editGroup;

      if (!updatedGroup) {
        return;
      }

      const identify = cache.identify(updatedGroup);

      if (!identify) {
        return;
      }

      cache.modify({
        fields: {
          groups: (existingRefs: readonly Reference[] = []) =>
            existingRefs.map(ref =>
              ref.__ref === identify ? { __ref: identify } : ref
            )
        }
      });
    },

    onCompleted: () => router.back(),

    onError: err => {
      Alert.alert('Error', err.message);
    }
  });

  const handleSubmit = (values: GroupFormValues) => {
    const input: CreateGroupInput = {
      ...values
    };

    void editGroup({
      variables: {
        id: groupId,
        input
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
