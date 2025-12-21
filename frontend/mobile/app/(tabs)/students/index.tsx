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
import { OptionalErrorMessage } from '@/components/OptionalErrorMessage';
import { StudentItem } from '@/components/StudentItem';
import { useAppTheme } from '@/hooks/useAppTheme';
import { type StudentResponse, studentService } from '@/services/student';

export default function StudentsScreen() {
  const [students, setStudents] = useState<StudentResponse[]>([]);
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [refreshing, setRefreshing] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const theme = useAppTheme();
  const deferredQuery = useDeferredValue(searchQuery);

  const listRef = useRef<FlatList>(null);
  useScrollToTop(listRef);

  const filteredStudents = useMemo(() => {
    const query = deferredQuery.trim().toLowerCase();
    return query
      ? students.filter(student =>
          student.fullName.toLowerCase().includes(query)
        )
      : students;
  }, [students, deferredQuery]);

  const fetchStudents = useCallback(async () => {
    try {
      setRefreshing(true);
      setError(null);
      const data = await studentService.getAllStudents();
      setStudents(data);
    } catch (error) {
      console.error(error);
      setError('Failed to load students');
    } finally {
      setRefreshing(false);
    }
  }, []);

  const renderItem = useCallback(
    ({ item }: { item: StudentResponse }) => (
      <StudentItem
        student={{
          id: item.id,
          fullName: item.fullName,
          groups: ['OTG-1'],
          isAttending: true,
          isPaid: false
        }}
      />
    ),
    []
  );

  const handleAddStudent = () => {
    console.log('Add student pressed');
  };

  useEffect(() => {
    void fetchStudents();
  }, [fetchStudents]);

  return (
    <>
      <CustomAppbar
        title='Students'
        badgeCount={filteredStudents.length}
        onAddPress={handleAddStudent}
      />

      <FlatList
        ref={listRef}
        style={{ flex: 1, backgroundColor: theme.colors.surfaceVariant }}
        data={filteredStudents}
        keyExtractor={item => item.id}
        renderItem={renderItem}
        contentContainerStyle={{ padding: 16, gap: 16 }}
        showsVerticalScrollIndicator={false}
        refreshing={refreshing}
        onRefresh={fetchStudents}
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
