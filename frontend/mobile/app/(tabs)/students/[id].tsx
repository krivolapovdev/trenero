import { gql } from '@apollo/client';
import { useQuery } from '@apollo/client/react';
import { useLocalSearchParams } from 'expo-router';
import { RefreshControl, ScrollView } from 'react-native';
import { Text } from 'react-native-paper';
import { CustomAppbar } from '@/components/CustomAppbar';
import { OptionalErrorMessage } from '@/components/OptionalErrorMessage';
import type { Student } from '@/graphql/types';
import { useAppTheme } from '@/hooks/useAppTheme';

const QUERY = gql`
    query ($id: UUID!) {
        student(id: $id) {
            id
            fullName
            phone
            birthDate
            note
            group {
                id
                name
            }
            attendances {
                id
                present
                createdAt
            }
            payments {
                id
                amount
                createdAt
            }
        }
    }
`;

export default function StudentByIdScreen() {
  const { id } = useLocalSearchParams();
  const theme = useAppTheme();

  const { data, loading, error, refetch } = useQuery<{ student: Student }>(
    QUERY,
    {
      variables: { id },
      fetchPolicy: 'cache-and-network'
    }
  );

  const student = data?.student;

  const handleEditPress = () => {
    console.log('Edit pressed');
  };

  const handleDeletePress = () => {
    console.log('Delete pressed');
  };

  return (
    <>
      <CustomAppbar
        title='Student'
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
        <Text>{JSON.stringify(student, null, 2)}</Text>
      </ScrollView>
    </>
  );
}
