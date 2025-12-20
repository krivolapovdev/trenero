import { useLocalSearchParams } from 'expo-router';
import { useCallback, useEffect, useState } from 'react';
import { RefreshControl, ScrollView } from 'react-native';
import { Text } from 'react-native-paper';
import { CustomAppbar } from '@/components/CustomAppbar';
import { useAppTheme } from '@/hooks/useAppTheme';

export default function StudentByIdScreen() {
  const [refreshing, setRefreshing] = useState<boolean>(false);

  const { id } = useLocalSearchParams();
  const theme = useAppTheme();

  const loadGroupById = useCallback(async () => {
    setRefreshing(true);
    try {
      await new Promise<void>(resolve => setTimeout(resolve, 3000));
    } finally {
      setRefreshing(false);
    }
  }, []);

  useEffect(() => {
    void loadGroupById();
  }, [loadGroupById]);

  return (
    <>
      <CustomAppbar
        title='Group'
        onEditPress={() => console.log('Edit pressed')}
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
            onRefresh={loadGroupById}
          />
        }
      >
        <Text>{id}</Text>
      </ScrollView>
    </>
  );
}
