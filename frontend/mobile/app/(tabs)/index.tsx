import { FlatList } from 'react-native';
import { useTheme } from 'react-native-paper';
import { AppbarWithBadge } from '@/components/AppbarWithBadge';
import { StudentItem } from '@/components/StudentItem';

const students = [
  {
    id: '1',
    fullName: 'Иван Иванов',
    groups: ['UTG-1', 'FALCON-4'],
    isAttending: true,
    isPaid: true
  },
  {
    id: '2',
    fullName: 'Петр Петров',
    groups: ['VB4-6', 'FAB-1'],
    isAttending: false,
    isPaid: false
  },
  {
    id: '3',
    fullName: 'Мария Сидорова',
    groups: ['UTG-1', 'FAB-1'],
    isAttending: true,
    isPaid: false
  },
  {
    id: '4',
    fullName: 'Алексей Козлов',
    groups: ['FALCON-4', 'VB4-6'],
    isAttending: true,
    isPaid: true
  },
  {
    id: '5',
    fullName: 'Елена Морозова',
    groups: ['FAB-1'],
    isAttending: false,
    isPaid: true
  },
  {
    id: '6',
    fullName: 'Дмитрий Федоров',
    groups: ['UTG-1'],
    isAttending: true,
    isPaid: true
  },
  {
    id: '7',
    fullName: 'Анна Кузнецова',
    groups: ['FALCON-4', 'FAB-1'],
    isAttending: true,
    isPaid: false
  },
  {
    id: '8',
    fullName: 'Сергей Васильев',
    groups: ['VB4-6'],
    isAttending: true,
    isPaid: true
  }
];

export default function StudentsScreen() {
  const theme = useTheme();

  return (
    <>
      <AppbarWithBadge
        title='Students'
        badgeCount={students.length}
      />

      <FlatList
        style={{ flex: 1, backgroundColor: theme.colors.surfaceVariant }}
        data={students}
        keyExtractor={item => item.id}
        renderItem={({ item }) => (
          <StudentItem
            student={item}
            onPress={student => console.log('Pressed:', student.id)}
          />
        )}
        contentContainerStyle={{ padding: 16, gap: 16 }}
        showsVerticalScrollIndicator={false}
      />
    </>
  );
}
