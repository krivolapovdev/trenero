import { useQuery } from '@apollo/client/react';
import { useScrollToTop } from '@react-navigation/native';
import { useRouter } from 'expo-router';
import { useCallback, useRef, useState } from 'react';
import { FlatList } from 'react-native';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import { StudentItem } from '@/src/components/StudentItem';
import { StudentSearchbarWithFilter } from '@/src/components/StudentSearchbarWithFilter';
import { GET_STUDENTS } from '@/src/graphql/queries';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { useFilteredStudents } from '@/src/hooks/useFilteredStudents';
import type { Status } from '@/src/types/student';

export default function StudentsScreen() {
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [filterKey, setFilterKey] = useState<number>(0);
  const [filterGroup, setFilterGroup] = useState<string | null>(null);
  const [filterStatus, setFilterStatus] = useState<Status | null>(null);

  const theme = useAppTheme();
  const router = useRouter();
  const listRef = useRef<FlatList>(null);
  useScrollToTop(listRef);

  const { data, loading, error, refetch } = useQuery(GET_STUDENTS, {
    fetchPolicy: 'cache-first'
  });
  const allStudents = data?.students ?? [];

  const filteredStudents = useFilteredStudents(
    allStudents,
    searchQuery,
    filterGroup,
    filterStatus
  );

  const renderItem = useCallback(
    ({ item }: { item: (typeof allStudents)[number] }) => (
      <StudentItem {...item} />
    ),
    []
  );

  const fetchStudents = useCallback(() => {
    setSearchQuery('');
    setFilterGroup(null);
    setFilterStatus(null);
    setFilterKey(key => key + 1);
    refetch();
  }, [refetch]);

  return (
    <>
      <CustomAppbar
        title='Students'
        badgeCount={filteredStudents.length}
        rightActions={[
          {
            icon: 'pencil-plus',
            onPress: () => router.navigate('/(tabs)/students/add-student')
          }
        ]}
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
              filterGroup={filterGroup}
              setFilterGroup={setFilterGroup}
              filterStatus={filterStatus}
              setFilterStatus={setFilterStatus}
            />
            <OptionalErrorMessage error={error?.message} />
          </>
        }
      />
    </>
  );
}
