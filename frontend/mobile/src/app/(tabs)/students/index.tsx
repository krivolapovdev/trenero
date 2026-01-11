import { useQuery } from '@apollo/client/react';
import { LegendList, type LegendListRef } from '@legendapp/list';
import { useScrollToTop } from '@react-navigation/native';
import { useRouter } from 'expo-router';
import { useCallback, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { StudentCard } from '@/src/components/Card';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import { StudentSearchbarWithFilter } from '@/src/components/Searchbar';
import type { GetStudentsQuery } from '@/src/graphql/__generated__/graphql';
import { GET_STUDENTS } from '@/src/graphql/queries';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { useFilteredStudents } from '@/src/hooks/useFilteredStudents';
import type { StudentStatus } from '@/src/types/student';

export default function StudentsScreen() {
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [filterKey, setFilterKey] = useState<number>(0);
  const [filterGroup, setFilterGroup] = useState<string | null>(null);
  const [filterStatus, setFilterStatus] = useState<StudentStatus | null>(null);

  const theme = useAppTheme();
  const router = useRouter();
  const { t } = useTranslation();
  const listRef = useRef<LegendListRef | null>(null);
  useScrollToTop(listRef);

  const { data, loading, error, refetch } = useQuery(GET_STUDENTS, {
    fetchPolicy: 'cache-first'
  });

  const filteredStudents = useFilteredStudents(
    data?.students ?? [],
    searchQuery,
    filterGroup,
    filterStatus
  );

  const renderItem = useCallback(
    ({ item }: { item: GetStudentsQuery['students'][number] }) => (
      <StudentCard {...item} />
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
        title={t('students')}
        mode='center-aligned'
        badgeCount={filteredStudents.length}
        rightActions={[
          {
            icon: 'pencil-plus',
            onPress: () => router.navigate('/(tabs)/students/create')
          }
        ]}
      />

      <LegendList
        ref={listRef}
        data={filteredStudents}
        keyExtractor={item => item.id}
        renderItem={renderItem}
        showsVerticalScrollIndicator={false}
        refreshing={loading}
        onRefresh={fetchStudents}
        keyboardShouldPersistTaps='handled'
        style={{ flex: 1, backgroundColor: theme.colors.surfaceVariant }}
        contentContainerStyle={{ paddingHorizontal: 16, gap: 16 }}
        columnWrapperStyle={{ gap: 16 }}
        recycleItems={true}
        maintainVisibleContentPosition={false}
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
