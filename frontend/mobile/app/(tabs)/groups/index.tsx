import { useScrollToTop } from '@react-navigation/native';
import {
  useCallback,
  useDeferredValue,
  useEffect,
  useMemo,
  useRef,
  useState
} from 'react';
import { FlatList } from 'react-native';
import { Searchbar } from 'react-native-paper';
import { CustomAppbar } from '@/components/CustomAppbar';
import { GroupItem } from '@/components/GroupItem';
import { OptionalErrorMessage } from '@/components/OptionalErrorMessage';
import { useAppTheme } from '@/hooks/useAppTheme';
import { type GroupResponse, groupService } from '@/services/group';

export default function GroupsScreen() {
  const [groups, setGroups] = useState<GroupResponse[]>([]);
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [refreshing, setRefreshing] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const theme = useAppTheme();
  const deferredQuery = useDeferredValue(searchQuery);

  const listRef = useRef<FlatList>(null);
  useScrollToTop(listRef);

  const filteredGroups = useMemo(() => {
    const query = deferredQuery.trim().toLowerCase();
    return query
      ? groups.filter(group => group.name.toLowerCase().includes(query))
      : groups;
  }, [groups, deferredQuery]);

  const fetchGroups = useCallback(async () => {
    try {
      setRefreshing(true);
      setError(null);
      const data = await groupService.getAllGroups();
      setGroups(data);
    } catch (error) {
      console.error(error);
      setError('Failed to load groups');
    } finally {
      setRefreshing(false);
    }
  }, []);

  const renderItem = useCallback(
    ({ item }: { item: GroupResponse }) => <GroupItem {...item} />,
    []
  );

  const handleAddGroup = () => {
    console.log('Add group pressed');
  };

  useEffect(() => {
    void fetchGroups();
  }, [fetchGroups]);

  return (
    <>
      <CustomAppbar
        title='Groups'
        badgeCount={filteredGroups.length}
        onAddPress={handleAddGroup}
      />

      <FlatList
        ref={listRef}
        style={{ flex: 1, backgroundColor: theme.colors.surfaceVariant }}
        data={filteredGroups}
        keyExtractor={item => item.id}
        renderItem={renderItem}
        contentContainerStyle={{ padding: 16, gap: 16 }}
        showsVerticalScrollIndicator={false}
        refreshing={refreshing}
        onRefresh={fetchGroups}
        ListHeaderComponent={
          <>
            <Searchbar
              placeholder='Search by name'
              value={searchQuery}
              onChangeText={setSearchQuery}
              style={{ backgroundColor: theme.colors.surface }}
              onClearIconPress={() => setSearchQuery('')}
            />
            <OptionalErrorMessage error={error} />
          </>
        }
      />
    </>
  );
}
