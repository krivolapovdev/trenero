import { gql } from '@apollo/client';
import { useQuery } from '@apollo/client/react';
import { useLocalSearchParams } from 'expo-router';
import { RefreshControl, ScrollView } from 'react-native';
import { Text } from 'react-native-paper';
import { CustomAppbar } from '@/components/CustomAppbar';
import { OptionalErrorMessage } from '@/components/OptionalErrorMessage';
import type { Group } from '@/graphql/types';
import { useAppTheme } from '@/hooks/useAppTheme';

const QUERY = gql`
    query ($id: UUID!) {
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
`;

export default function GroupByIdScreen() {
  const { id } = useLocalSearchParams();
  const theme = useAppTheme();

  const { data, loading, error, refetch } = useQuery<{ group: Group }>(QUERY, {
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
        showBackButton={true}
        onEditPress={handleEditPress}
        onDeletePress={handleDeletePress}
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
