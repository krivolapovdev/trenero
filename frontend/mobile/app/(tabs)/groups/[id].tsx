import { useLocalSearchParams } from 'expo-router';
import { useCallback, useEffect, useState } from 'react';
import { RefreshControl, ScrollView } from 'react-native';
import { Text } from 'react-native-paper';
import { CustomAppbar } from '@/components/CustomAppbar';
import { OptionalErrorMessage } from '@/components/OptionalErrorMessage';
import { useAppTheme } from '@/hooks/useAppTheme';
import { type GroupResponse, groupService } from '@/services/group';

export default function GroupByIdScreen() {
  const [group, setGroup] = useState<GroupResponse | null>(null);
  const [refreshing, setRefreshing] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const { id } = useLocalSearchParams();
  const theme = useAppTheme();

  const fetchGroupById = useCallback(async () => {
    try {
      setRefreshing(true);
      setError(null);
      const data = await groupService.getGroupById(id as string);
      setGroup(data);
    } catch (err) {
      console.error(err);
      setError(`Failed to load group: ${id}`);
    } finally {
      setRefreshing(false);
    }
  }, [id]);

  const handleEditPress = () => {
    console.log('Edit pressed');
  };

  const handleDeletePress = () => {
    console.log('Delete pressed');
  };

  useEffect(() => {
    void fetchGroupById();
  }, [fetchGroupById]);

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
            refreshing={refreshing}
            onRefresh={fetchGroupById}
          />
        }
      >
        <OptionalErrorMessage error={error} />
        <Text>{id}</Text>
        <Text>{JSON.stringify(group, null, 2)}</Text>
      </ScrollView>
    </>
  );
}
