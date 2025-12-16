import { useState } from 'react';
import { FlatList } from 'react-native';
import { Searchbar, useTheme } from 'react-native-paper';
import { AppbarWithBadge } from '@/components/AppbarWithBadge';
import { GroupItem } from '@/components/GroupItem';

type GroupResponse = {
  id: string;
  name: string;
  countOfStudents: number;
};

const groups: GroupResponse[] = [
  { id: '1', name: 'OTG-1', countOfStudents: 10 },
  { id: '2', name: 'FALCON-4', countOfStudents: 30 },
  { id: '3', name: 'URN-4', countOfStudents: 40 },
  { id: '4', name: 'BATTLE-65', countOfStudents: 53 },
  { id: '5', name: 'УТК-3', countOfStudents: 544 },
  { id: '6', name: 'УТК-4', countOfStudents: 44 },
  { id: '7', name: 'УТК-5', countOfStudents: 544 },
  { id: '8', name: 'УТК-6', countOfStudents: 655 },
  { id: '9', name: 'УТК-7', countOfStudents: 76 },
  { id: '10', name: 'УТК-8', countOfStudents: 98 },
  { id: '11', name: 'УТК-9', countOfStudents: 7 },
  { id: '12', name: 'УТК-10', countOfStudents: 94 },
  { id: '13', name: 'УТК-11', countOfStudents: 445 }
];

export default function GroupsScreen() {
  const theme = useTheme();

  const [searchQuery, setSearchQuery] = useState('');
  const [refreshing, setRefreshing] = useState(false);

  const filteredGroups = searchQuery.trim()
    ? groups.filter(group =>
        group.name.toLowerCase().includes(searchQuery.toLowerCase())
      )
    : groups;

  const handleRefresh = async () => {
    setRefreshing(true);

    try {
      console.log('refreshing...');
    } finally {
      setRefreshing(false);
    }
  };

  return (
    <>
      <AppbarWithBadge
        title='Groups'
        badgeCount={filteredGroups.length}
      />

      <FlatList
        style={{ flex: 1, backgroundColor: theme.colors.surfaceVariant }}
        data={filteredGroups}
        keyExtractor={item => item.id}
        ListHeaderComponent={
          <Searchbar
            placeholder='Search by name'
            value={searchQuery}
            onChangeText={setSearchQuery}
            style={{ backgroundColor: theme.colors.surface }}
            onClearIconPress={() => setSearchQuery('')}
          />
        }
        renderItem={({ item }) => <GroupItem group={item} />}
        contentContainerStyle={{ padding: 16, gap: 16 }}
        showsVerticalScrollIndicator={false}
        refreshing={refreshing}
        onRefresh={handleRefresh}
      />
    </>
  );
}
