import { gql } from '@apollo/client';
import { useLazyQuery } from '@apollo/client/react';
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
import { AddGroupDialog } from '@/components/dialogs';
import { GroupItem } from '@/components/GroupItem';
import { OptionalErrorMessage } from '@/components/OptionalErrorMessage';
import type { Group } from '@/graphql/types';
import { useAppTheme } from '@/hooks/useAppTheme';
import { useAppStore } from '@/stores/appStore';

const QUERY = gql`
    query {
        groups {
            id
            name
            defaultPrice
            students {
                id
            }
        }
    }
`;

export default function GroupsScreen() {
  const theme = useAppTheme();

  const groups = useAppStore(state => state.groups);
  const setGroups = useAppStore(state => state.setGroups);

  const [showAddModal, setShowAddModal] = useState<boolean>(false);

  const [searchQuery, setSearchQuery] = useState<string>('');
  const deferredQuery = useDeferredValue(searchQuery);

  const listRef = useRef<FlatList>(null);
  useScrollToTop(listRef);

  const [loadGroups, { loading, data, error }] = useLazyQuery<{
    groups: Group[];
  }>(QUERY, {
    fetchPolicy: 'network-only'
  });

  const filteredGroups = useMemo(() => {
    const query = deferredQuery.trim().toLowerCase();
    return query
      ? groups.filter(group => group.name.toLowerCase().includes(query))
      : groups;
  }, [groups, deferredQuery]);

  const fetchGroups = useCallback(() => {
    setSearchQuery('');
    loadGroups();
  }, [loadGroups]);

  const renderItem = useCallback(
    ({ item }: { item: Group }) => <GroupItem {...item} />,
    []
  );

  const handleGroupAdded = useCallback(
    (newGroup: Group) => {
      setGroups([newGroup, ...groups]);
      setShowAddModal(false);
      listRef.current?.scrollToOffset({ offset: 0, animated: true });
    },
    [setGroups, groups]
  );

  useEffect(() => {
    if (data?.groups) {
      setGroups(data.groups);
    }

    if (error) {
      console.error(error);
    }
  }, [data, error, setGroups]);

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
