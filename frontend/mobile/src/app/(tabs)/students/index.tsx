import { LegendList, type LegendListRef } from '@legendapp/list';
import { useScrollToTop } from '@react-navigation/native';
import { useRouter } from 'expo-router';
import { useCallback, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { StudentCard } from '@/src/components/Card';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import { StudentSearchbarWithFilter } from '@/src/components/Searchbar';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { useFilteredStudents } from '@/src/hooks/useFilteredStudents';
import { useGroupsStore } from '@/src/stores/groupsStore';
import { useStudentsStore } from '@/src/stores/studentsStore';
import type { StudentOverview, StudentStatus } from '@/src/types/student';

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

  const groupsRecord = useGroupsStore(state => state.allGroups);
  const studentsRecord = useStudentsStore(state => state.allStudents);
  const isRefreshing = useStudentsStore(state => state.isRefreshing);
  const error = useStudentsStore(state => state.error);
  const refreshStudents = useStudentsStore(state => state.refreshStudents);

  const filteredStudents = useFilteredStudents(
    studentsRecord,
    searchQuery,
    filterGroup,
    filterStatus
  );

  const renderItem = useCallback(
    (props: { item: StudentOverview }) => <StudentCard student={props.item} />,
    []
  );

  const handleRefresh = useCallback(async () => {
    setSearchQuery('');
    setFilterKey(key => key + 1);
    setFilterGroup(null);
    setFilterStatus(null);
    await refreshStudents();
  }, [refreshStudents]);

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

      <OptionalErrorMessage error={error} />

      <LegendList
        ref={listRef}
        data={filteredStudents}
        keyExtractor={item => item.id}
        renderItem={renderItem}
        showsVerticalScrollIndicator={false}
        refreshing={isRefreshing}
        onRefresh={handleRefresh}
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
            groupsRecord={groupsRecord}
          />
        }
      />
    </>
  );
}
