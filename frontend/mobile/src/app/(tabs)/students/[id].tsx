import { useQuery } from '@apollo/client/react';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { RefreshControl, ScrollView } from 'react-native';
import { Text } from 'react-native-paper';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import { graphql } from '@/src/graphql/__generated__';
import { useAppTheme } from '@/src/hooks/useAppTheme';

const GET_STUDENT = graphql(`
    query GetStudent($id: UUID!) {
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
`);

export default function StudentByIdScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const theme = useAppTheme();
  const router = useRouter();

  const { data, loading, error, refetch } = useQuery(GET_STUDENT, {
    variables: { id },
    fetchPolicy: 'cache-and-network'
  });

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
        <Text>{JSON.stringify(student, null, 2)}</Text>
      </ScrollView>
    </>
  );
}
