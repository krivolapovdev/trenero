import {
  useCallback,
  useDeferredValue,
  useEffect,
  useMemo,
  useState
} from 'react';
import { FlatList } from 'react-native';
import { Searchbar } from 'react-native-paper';
import { AppbarWithBadge } from '@/components/AppbarWithBadge';
import { StudentItem } from '@/components/StudentItem';
import { useAppTheme } from '@/hooks/useAppTheme';
import type { StudentResponse } from '@/services/student/student.types';
import { studentService } from '@/services/student/studentService';

export default function StudentsScreen() {
  const [students, setStudents] = useState<StudentResponse[]>([]);
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [refreshing, setRefreshing] = useState<boolean>(false);

  const theme = useAppTheme();
  const deferredQuery = useDeferredValue(searchQuery);

  const filteredStudents = useMemo(() => {
    const query = deferredQuery.trim().toLowerCase();
    return query
      ? students.filter(student =>
          student.fullName.toLowerCase().includes(query)
        )
      : students;
  }, [students, deferredQuery]);

  const loadStudents = useCallback(async () => {
    try {
      setRefreshing(true);
      const data = await studentService.getAllUsers();
      setStudents(data);
    } catch (error) {
      console.error('Failed to load students', error);
    } finally {
      setRefreshing(false);
    }
  }, []);

  useEffect(() => {
    void loadStudents();
  }, [loadStudents]);

  return (
    <>
      <AppbarWithBadge
        title='Students'
        badgeCount={filteredStudents.length}
        onAddPress={() => console.log('Add student pressed')}
      />

      <FlatList
        style={{ flex: 1, backgroundColor: theme.colors.surfaceVariant }}
        data={filteredStudents}
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
        renderItem={({ item }) => (
          <StudentItem
            student={{
              id: item.id,
              fullName: item.fullName,
              groups: ['OTG-1'],
              isAttending: true,
              isPaid: false
            }}
          />
        )}
        contentContainerStyle={{ padding: 16, gap: 16 }}
        showsVerticalScrollIndicator={false}
        refreshing={refreshing}
        onRefresh={loadStudents}
      />
    </>
  );
}
