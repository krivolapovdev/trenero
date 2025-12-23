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
import { CustomAppbar } from '@/components/CustomAppbar';
import { AddStudentDialog } from '@/components/dialogs/AddStudentDialog';
import { OptionalErrorMessage } from '@/components/OptionalErrorMessage';
import { StudentItem } from '@/components/StudentItem';
import { StudentSearchbarWithFilter } from '@/components/StudentSearchbarWithFilter';
import { useAppTheme } from '@/hooks/useAppTheme';
import { studentService } from '@/services/student';
import { useAppStore } from '@/stores/appStore';
import type { StudentResponse } from '@/types/student';

export default function StudentsScreen() {
  const students = useAppStore(state => state.students);
  const setStudents = useAppStore(state => state.setStudents);

  const [refreshing, setRefreshing] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [showAddModal, setShowAddModal] = useState<boolean>(false);

  const [searchQuery, setSearchQuery] = useState<string>('');
  const [selectedGroup, setSelectedGroup] = useState<string | null>('All');
  const [selectedStatus, setSelectedStatus] = useState<
    'All' | 'Attending' | 'Paid'
  >('All');

  const theme = useAppTheme();
  const deferredQuery = useDeferredValue(searchQuery);

  const listRef = useRef<FlatList>(null);
  useScrollToTop(listRef);

  const filteredStudents = useMemo(() => {
    const query = deferredQuery.trim().toLowerCase();

    return students.filter(student => {
      if (query && !student.fullName.toLowerCase().includes(query)) {
        return false;
      }

      if (selectedGroup !== 'All' && student.group?.name !== selectedGroup) {
        return false;
      }

      if (selectedStatus !== 'All') {
        if (selectedStatus === 'Attending' && !student.isAttending) {
          return false;
        }

        if (selectedStatus === 'Paid' && !student.isPaid) {
          return false;
        }
      }

      return true;
    });
  }, [students, deferredQuery, selectedGroup, selectedStatus]);

  const fetchStudents = useCallback(async () => {
    try {
      setRefreshing(true);
      setError(null);
      setSelectedGroup('All');
      setSelectedStatus('All');
      const data = await studentService.getAllStudents();
      setStudents(data);
    } catch (error) {
      console.error(error);
      setError('Failed to load students');
    } finally {
      setRefreshing(false);
    }
  }, [setStudents]);

  const renderItem = useCallback(
    ({ item }: { item: StudentResponse }) => <StudentItem {...item} />,
    []
  );

  const handleStudentAdded = useCallback(
    (student: StudentResponse) => {
      setStudents([student, ...students]);
      setShowAddModal(false);
      setSelectedGroup('All');
      setSelectedStatus('All');
      listRef.current?.scrollToOffset({ offset: 0, animated: true });
    },
    [students, setStudents]
  );

  useEffect(() => {
    void fetchStudents();
  }, [fetchStudents]);

  return (
    <>
      <CustomAppbar
        title='Students'
        badgeCount={filteredStudents.length}
        onAddPress={() => setShowAddModal(true)}
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
        keyboardShouldPersistTaps='handled'
        ListHeaderComponent={
          <>
            <StudentSearchbarWithFilter
              value={searchQuery}
              onChange={setSearchQuery}
              onClear={() => setSearchQuery('')}
              onFilter={({ group, status }) => {
                setSelectedGroup(group);
                setSelectedStatus(status);
              }}
            />
            <OptionalErrorMessage error={error} />
          </>
        }
      />

      <AddStudentDialog
        visible={showAddModal}
        onDismiss={() => setShowAddModal(false)}
        onStudentAdded={handleStudentAdded}
      />
    </>
  );
}
