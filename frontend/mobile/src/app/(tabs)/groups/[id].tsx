import { useMutation, useQuery } from '@apollo/client/react';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { Alert, RefreshControl, ScrollView } from 'react-native';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { GroupItem } from '@/src/components/GroupItem';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import { graphql } from '@/src/graphql/__generated__';
import { useAppTheme } from '@/src/hooks/useAppTheme';

const GET_GROUP = graphql(`
    query GetGroup($id: UUID!) {
        group(id: $id) {
            id
            name
            defaultPrice
            students {
                id
                fullName
            }
            lessons {
                id
                startDateTime
            }
        }
    }
`);

const DELETE_GROUP = graphql(`
    mutation DeleteGroup($id: UUID!) {
        deleteGroup(id: $id) {
            id
        }
    }
`);

export default function GroupByIdScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const theme = useAppTheme();
  const router = useRouter();

  const { data, loading, error, refetch } = useQuery(GET_GROUP, {
    variables: { id },
    fetchPolicy: 'cache-and-network'
  });

  const [deleteGroup, resultDeleteGroup] = useMutation(DELETE_GROUP, {
    variables: { id },

    update(cache, { data }) {
      if (!data?.deleteGroup) {
        return;
      }

      cache.evict({ id: cache.identify(data.deleteGroup) });
      cache.gc();
    },

    onCompleted: () => {
      router.back();
    },

    onError: err => {
      Alert.alert('Error', err.message);
    }
  });

  const handleEditPress = () => {
    console.log('Edit pressed');
  };

  const handleDeletePress = () => {
    Alert.alert(
      'Delete Group',
      `Are you sure you want to delete ${group?.name || 'this group'}?`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: () => {
            void deleteGroup();
          }
        }
      ]
    );
  };

  const group = data?.group;

  return (
    <>
      <CustomAppbar
        title='Group'
        leftActions={[
          {
            icon: 'arrow-left',
            onPress: () => router.back(),
            disabled: resultDeleteGroup.loading
          }
        ]}
        rightActions={[
          {
            icon: 'account-edit',
            onPress: () => handleEditPress(),
            disabled: loading || resultDeleteGroup.loading
          },
          {
            icon: 'trash-can',
            onPress: () => handleDeletePress(),
            disabled: loading || resultDeleteGroup.loading
          }
        ]}
      />

      <ScrollView
        contentContainerStyle={{ padding: 16 }}
        showsVerticalScrollIndicator={false}
        style={{
          flex: 1,
          backgroundColor: theme.colors.surfaceVariant
        }}
        refreshControl={
          <RefreshControl
            refreshing={loading}
            onRefresh={refetch}
          />
        }
      >
        <OptionalErrorMessage error={error?.message} />

        {group && <GroupItem {...group} />}
      </ScrollView>
    </>
  );
}
