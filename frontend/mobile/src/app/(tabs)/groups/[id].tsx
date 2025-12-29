import { useQuery } from '@apollo/client/react';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { RefreshControl, ScrollView } from 'react-native';
import { Text } from 'react-native-paper';
import { CustomAppbar } from '@/src/components/CustomAppbar';
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

export default function GroupByIdScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const theme = useAppTheme();
  const router = useRouter();

  const { data, loading, error, refetch } = useQuery(GET_GROUP, {
    variables: { id },
    fetchPolicy: 'cache-and-network'
  });
  const group = data?.group;

  const handleEditPress = () => {
    console.log('Edit pressed');
  };

  const handleDeletePress = () => {
    console.log('Delete pressed');
  };

  return (
    <>
      <CustomAppbar
        title='Group'
        leftActions={[{ icon: 'arrow-left', onPress: () => router.back() }]}
        rightActions={[
          { icon: 'account-edit', onPress: () => handleEditPress() },
          { icon: 'trash-can', onPress: () => handleDeletePress() }
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
        <Text>{id}</Text>
        <Text>{JSON.stringify(group, null, 2)}</Text>
      </ScrollView>
    </>
  );
}
