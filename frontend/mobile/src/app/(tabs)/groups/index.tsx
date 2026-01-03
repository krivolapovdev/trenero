import { useQuery } from '@apollo/client/react';
import { LegendList, type LegendListRef } from '@legendapp/list';
import { useScrollToTop } from '@react-navigation/native';
import { useRouter } from 'expo-router';
import { useCallback, useRef, useState } from 'react';
import { Searchbar } from 'react-native-paper';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { GroupItem } from '@/src/components/GroupItem';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import type { GetGroupsQuery } from '@/src/graphql/__generated__/graphql';
import { GET_GROUPS } from '@/src/graphql/queries';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { useFilteredGroups } from '@/src/hooks/useFilteredGroups';

export default function GroupsScreen() {
  const theme = useAppTheme();
  const router = useRouter();

  const [searchQuery, setSearchQuery] = useState<string>('');

  const listRef = useRef<LegendListRef | null>(null);
  useScrollToTop(listRef);

  const { loading, data, error, refetch } = useQuery(GET_GROUPS, {
    fetchPolicy: 'cache-first'
  });

  const filteredGroups = useFilteredGroups(data?.groups ?? [], searchQuery);

  const fetchGroups = useCallback(() => {
    setSearchQuery('');
    refetch();
  }, [refetch]);

  const renderItem = useCallback(
    ({ item }: { item: GetGroupsQuery['groups'][number] }) => (
      <GroupItem {...item} />
    ),
    []
  );

  return (
    <>
      <CustomAppbar
        title='Groups'
        badgeCount={filteredGroups.length}
        rightActions={[
          {
            icon: 'pencil-plus',
            onPress: () => router.navigate('/(tabs)/groups/add-group')
          }
        ]}
      />

      <LegendList
        ref={listRef}
        data={filteredGroups}
        keyExtractor={item => item.id}
        renderItem={renderItem}
        showsVerticalScrollIndicator={false}
        refreshing={loading}
        onRefresh={fetchGroups}
        keyboardShouldPersistTaps='handled'
        style={{ flex: 1, backgroundColor: theme.colors.surfaceVariant }}
        contentContainerStyle={{ paddingHorizontal: 16, gap: 16 }}
        columnWrapperStyle={{ gap: 16 }}
        recycleItems={true}
        maintainVisibleContentPosition={true}
        ListHeaderComponent={
          <>
            <Searchbar
              placeholder='Search by name'
              value={searchQuery}
              onChangeText={setSearchQuery}
              style={{ backgroundColor: theme.colors.surface }}
              onClearIconPress={() => setSearchQuery('')}
            />
            <OptionalErrorMessage error={error?.message} />
          </>
        }
      />
    </>
  );
}
