import { LegendList, type LegendListRef } from '@legendapp/list';
import { useScrollToTop } from '@react-navigation/native';
import { useRouter } from 'expo-router';
import { useCallback, useRef, useState } from 'react';
import { useAsyncCallback } from 'react-async-hook';
import { useTranslation } from 'react-i18next';
import { studentService } from '@/src/api/services/student/studentService';
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

  const students = useStudentsStore(state => state.allStudents);
  const groups = useGroupsStore(state => state.allGroups);
  const setAllStudents = useStudentsStore(state => state.setAllStudents);

  const { loading, execute, error } = useAsyncCallback(async () => {
    const data = await studentService.getOverview();
    setAllStudents(data);
    return data;
  });

  const filteredStudents = useFilteredStudents(
    students,
    searchQuery,
    filterGroup,
    filterStatus
  );

  const renderItem = useCallback(
    (props: { item: StudentOverview }) => <StudentCard student={props.item} />,
    []
  );

  const refreshData = useCallback(async () => {
    setSearchQuery('');
    setFilterGroup(null);
    setFilterStatus(null);
    setFilterKey(key => key + 1);
    await execute();
  }, [execute]);

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

      <OptionalErrorMessage error={error?.message} />

      <LegendList
        ref={listRef}
        data={filteredStudents}
        keyExtractor={item => item.id}
        renderItem={renderItem}
        showsVerticalScrollIndicator={false}
        refreshing={loading}
        onRefresh={refreshData}
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
            groupsRecord={groups}
          />
        }
      />
    </>
  );
}
