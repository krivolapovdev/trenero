import { useQuery } from '@apollo/client/react';
import { useScrollToTop } from '@react-navigation/native';
import {
  useCallback,
  useDeferredValue,
  useMemo,
  useRef,
  useState
} from 'react';
import { FlatList } from 'react-native';
import { Searchbar } from 'react-native-paper';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { AddGroupDialog } from '@/src/components/dialogs';
import { GroupItem } from '@/src/components/GroupItem';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import { GET_GROUPS } from '@/src/graphql/queries';
import { useAppTheme } from '@/src/hooks/useAppTheme';

export default function GroupsScreen() {
  const theme = useAppTheme();

  const [showAddModal, setShowAddModal] = useState<boolean>(false);

  const [searchQuery, setSearchQuery] = useState<string>('');
  const deferredQuery = useDeferredValue(searchQuery);

  const listRef = useRef<FlatList>(null);
  useScrollToTop(listRef);

  const { loading, data, error, refetch } = useQuery(GET_GROUPS, {
    fetchPolicy: 'cache-first'
  });
  const allGroups = data?.groups ?? [];

  const filteredGroups = useMemo(() => {
    const query = deferredQuery.trim().toLowerCase();
    return query
      ? allGroups.filter(group => group.name.toLowerCase().includes(query))
      : allGroups;
  }, [allGroups, deferredQuery]);

  const fetchGroups = useCallback(() => {
    setSearchQuery('');
    refetch();
  }, [refetch]);

  const renderItem = useCallback(
    ({ item }: { item: (typeof allGroups)[number] }) => <GroupItem {...item} />,
    []
  );

  const handleGroupAdded = useCallback(() => {
    setShowAddModal(false);
    listRef.current?.scrollToOffset({ offset: 0, animated: true });
  }, []);

  return (
    <>
      <CustomAppbar
        title='Groups'
        badgeCount={filteredGroups.length}
        onAddPress={() => setShowAddModal(true)}
      />

      <FlatList
        ref={listRef}
        style={{ flex: 1, backgroundColor: theme.colors.surfaceVariant }}
        data={filteredGroups}
        keyExtractor={item => item.id}
        renderItem={renderItem}
        contentContainerStyle={{ padding: 16, gap: 16 }}
        showsVerticalScrollIndicator={false}
        refreshing={loading}
        onRefresh={fetchGroups}
        keyboardShouldPersistTaps='handled'
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

      <AddGroupDialog
        visible={showAddModal}
        onDismiss={() => setShowAddModal(false)}
        onGroupAdded={handleGroupAdded}
      />
    </>
  );
}
