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
import { CustomAppbar } from '@/components/CustomAppbar';
import { AddStudentDialog } from '@/components/dialogs/AddStudentDialog';
import { OptionalErrorMessage } from '@/components/OptionalErrorMessage';
import { StudentItem } from '@/components/StudentItem';
import { StudentSearchbarWithFilter } from '@/components/StudentSearchbarWithFilter';
import type { Student } from '@/graphql/types';
import { useAppTheme } from '@/hooks/useAppTheme';
import { useAppStore } from '@/stores/appStore';

const QUERY = gql`
    query {
        students {
            id
            fullName
            group {
                id
                name
            }
        }
    }
`;

export default function StudentsScreen() {
  const students = useAppStore(state => state.students);
  const setStudents = useAppStore(state => state.setStudents);

  const [showAddModal, setShowAddModal] = useState<boolean>(false);

  const [searchQuery, setSearchQuery] = useState<string>('');
  const [selectedGroup, setSelectedGroup] = useState<string | null>('All');
  const [selectedStatus, setSelectedStatus] = useState<
    'All' | 'Attending' | 'Paid'
  >('All');
  const [filterKey, setFilterKey] = useState<number>(0);

  const theme = useAppTheme();
  const deferredQuery = useDeferredValue(searchQuery);

  const listRef = useRef<FlatList>(null);
  useScrollToTop(listRef);

  const [loadStudents, { loading, data, error }] = useLazyQuery<{
    students: Student[];
  }>(QUERY, {
    fetchPolicy: 'network-only'
  });

  const filteredStudents = useMemo(() => {
    const query = deferredQuery.trim().toLowerCase();

    return students.filter(student => {
      if (query && !student.fullName.toLowerCase().includes(query)) {
        return false;
      }

      if (selectedGroup !== 'All' && student.group?.name !== selectedGroup) {
        return false;
      }

      // if (selectedStatus !== 'All') {
      //   if (selectedStatus === 'Attending' && !student.isAttending) {
      //     return false;
      //   }
      //
      //   if (selectedStatus === 'Paid' && !student.isPaid) {
      //     return false;
      //   }
      // }

      return true;
    });
  }, [students, deferredQuery, selectedGroup]);

  const renderItem = useCallback(
    ({ item }: { item: Student }) => <StudentItem {...item} />,
    []
  );

  const fetchStudents = useCallback(() => {
    setSearchQuery('');
    setSelectedGroup('All');
    setSelectedStatus('All');
    setFilterKey(key => key + 1);
    loadStudents();
  }, [loadStudents]);

  const handleStudentAdded = useCallback(
    (newStudent: Student) => {
      setStudents([newStudent, ...students]);
      setShowAddModal(false);
      setSelectedGroup('All');
      setSelectedStatus('All');
      listRef.current?.scrollToOffset({ offset: 0, animated: true });
    },
    [students, setStudents]
  );

  useEffect(() => {
    if (data?.students) {
      setStudents(data.students);
    }

    if (error) {
      console.error(error);
    }
  }, [data, error, setStudents]);

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
        refreshing={loading}
        onRefresh={fetchStudents}
        keyboardShouldPersistTaps='handled'
        ListHeaderComponent={
          <>
            <StudentSearchbarWithFilter
              key={filterKey}
              value={searchQuery}
              onChange={setSearchQuery}
              onClearIconPress={() => setSearchQuery('')}
              onFilter={({ group, status }) => {
                setSelectedGroup(group);
                setSelectedStatus(status);
              }}
            />
            <OptionalErrorMessage error={error?.message} />
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
