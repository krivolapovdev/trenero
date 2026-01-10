import type { Reference } from '@apollo/client';
import { useMutation } from '@apollo/client/react';
import { useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import { GroupForm, type GroupFormValues } from '@/src/components/GroupForm';
import { graphql } from '@/src/graphql/__generated__';
import type { CreateGroupInput } from '@/src/graphql/__generated__/graphql';

const CREATE_GROUP = graphql(`
    mutation CreateGroup($input: CreateGroupInput!) {
        createGroup(input: $input) {
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

export default function CreateGroupScreen() {
  const { t } = useTranslation();
  const router = useRouter();

  const [createGroup, { loading }] = useMutation(CREATE_GROUP, {
    update(cache, { data }) {
      const newGroup = data?.createGroup;

      if (!newGroup) {
        return;
      }

      const identify = cache.identify(newGroup);

      if (!identify) {
        return;
      }

      cache.modify({
        fields: {
          groups: (existingRefs: readonly Reference[] = []) => [
            {
              __ref: identify
            },
            ...existingRefs
          ]
        }
      });
    },

    onCompleted: data => {
      router.replace(`/(tabs)/groups/${data.createGroup.id}`);
    },

    onError: err => {
      Alert.alert('Error', err.message);
    }
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
      loading={loading}
    />
  );
}
