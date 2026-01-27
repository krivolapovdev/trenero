import { LegendList, type LegendListRef } from '@legendapp/list';
import { useScrollToTop } from '@react-navigation/native';
import { useRouter } from 'expo-router';
import { useCallback, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { api } from '@/src/api';
import type { components } from '@/src/api/generated/openapi';
import { StudentCard } from '@/src/components/Card';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { StudentSearchbarWithFilter } from '@/src/components/Searchbar';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { useFilteredStudents } from '@/src/hooks/useFilteredStudents';
import type { StudentStatus } from '@/src/types/student';

export default function StudentsScreen() {
  const [searchQuery, setSearchQuery] = useState('');
  const [filterKey, setFilterKey] = useState(0);
  const [filterGroup, setFilterGroup] = useState<string | null>(null);
  const [filterStatus, setFilterStatus] = useState<StudentStatus | null>(null);

  const theme = useAppTheme();
  const router = useRouter();
  const { t } = useTranslation();

  const listRef = useRef<LegendListRef | null>(null);
  useScrollToTop(listRef);

  const {
    data: studentsWrapper,
    isPending: studentPending,
    refetch
  } = api.useQuery('get', '/api/v1/students/overview');

  const filteredStudents = useFilteredStudents(
    studentsWrapper?.students ?? [],
    searchQuery,
    filterGroup,
    filterStatus
  );

  const renderItem = useCallback(
    (props: { item: components['schemas']['StudentOverviewResponse'] }) => (
      <StudentCard student={props.item} />
    ),
    []
  );

  const fetchStudents = useCallback(() => {
    setSearchQuery('');
    setFilterGroup(null);
    setFilterStatus(null);
    setFilterKey(key => key + 1);

    void refetch();
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
        refreshing={studentPending}
        onRefresh={fetchStudents}
        keyboardShouldPersistTaps='handled'
        style={{ flex: 1, backgroundColor: theme.colors.surfaceVariant }}
        contentContainerStyle={{ paddingHorizontal: 16, gap: 16 }}
        columnWrapperStyle={{ gap: 16 }}
        recycleItems={true}
        maintainVisibleContentPosition={false}
        ListHeaderComponent={
          <StudentSearchbarWithFilter
            key={filterKey}
            value={searchQuery}
            onChange={setSearchQuery}
            onClearIconPress={() => setSearchQuery('')}
            filterGroup={filterGroup}
            setFilterGroup={setFilterGroup}
            filterStatus={filterStatus}
            setFilterStatus={setFilterStatus}
            groups={studentsWrapper?.allGroups ?? []}
          />
        }
      />
    </>
  );
}
