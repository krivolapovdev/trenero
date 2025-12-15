import { FlatList, StyleSheet, View } from 'react-native';
import { Appbar, Badge, Text, useTheme } from 'react-native-paper';
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

  const handleGroupPress = (group: GroupResponse) => {
    console.log('Pressed', group.name);
  };

  return (
    <>
      <Appbar.Header
        mode='center-aligned'
        elevated
      >
        <Appbar.Content
          title={
            <View
              style={{
                alignItems: 'center',
                display: 'flex',
                flexDirection: 'row'
              }}
            >
              <Text variant='titleLarge'>Groups</Text>
              <Badge
                style={[
                  styles.badge,
                  {
                    backgroundColor: theme.colors.secondaryContainer,
                    color: theme.colors.onSecondaryContainer
                  }
                ]}
              >
                {groups.length}
              </Badge>
            </View>
          }
        />
      </Appbar.Header>

      <FlatList
        style={{ flex: 1, backgroundColor: theme.colors.surfaceVariant }}
        data={groups}
        keyExtractor={item => item.id}
        renderItem={({ item }) => (
          <GroupItem
            group={item}
            onPress={handleGroupPress}
          />
        )}
        contentContainerStyle={styles.listContent}
        showsVerticalScrollIndicator={false}
      />
    </>
  );
}

const styles = StyleSheet.create({
  listContent: {
    padding: 12
  },
  badge: {
    position: 'absolute',
    top: -10,
    right: -20
  }
});
