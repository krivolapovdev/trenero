import { LegendList, type LegendListRef } from '@legendapp/list';
import { useScrollToTop } from '@react-navigation/native';
import { useRouter } from 'expo-router';
import { useCallback, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Searchbar } from 'react-native-paper';
import { api } from '@/src/api';
import type { components } from '@/src/api/generated/openapi';
import { GroupCard } from '@/src/components/Card';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { useFilteredGroups } from '@/src/hooks/useFilteredGroups';

export default function GroupsScreen() {
  const theme = useAppTheme();
  const router = useRouter();
  const { t } = useTranslation();

  const [searchQuery, setSearchQuery] = useState<string>('');

  const listRef = useRef<LegendListRef | null>(null);
  useScrollToTop(listRef);

  const { data, isPending, error, refetch } = api.useQuery(
    'get',
    '/api/v1/groups/overview'
  );

  const filteredGroups = useFilteredGroups(data ?? [], searchQuery);

  const fetchGroups = useCallback(() => {
    setSearchQuery('');
    void refetch();
  }, [refetch]);

  const renderItem = useCallback(
    ({ item }: { item: components['schemas']['GroupOverviewResponse'] }) => (
      <GroupCard {...item} />
    ),
    []
  );

  return (
    <>
      <CustomAppbar
        title={t('groups')}
        mode='center-aligned'
        badgeCount={filteredGroups.length}
        rightActions={[
          {
            icon: 'pencil-plus',
            onPress: () => router.navigate('/(tabs)/groups/create')
          }
        ]}
      />

      <LegendList
        ref={listRef}
        data={filteredGroups}
        keyExtractor={item => item.id}
        renderItem={renderItem}
        showsVerticalScrollIndicator={false}
        refreshing={isPending}
        onRefresh={fetchGroups}
        keyboardShouldPersistTaps='handled'
        style={{ flex: 1, backgroundColor: theme.colors.surfaceVariant }}
        contentContainerStyle={{ paddingHorizontal: 16, gap: 16 }}
        columnWrapperStyle={{ gap: 16 }}
        recycleItems={true}
        maintainVisibleContentPosition={false}
        ListHeaderComponent={
          <>
            <Searchbar
              placeholder={t('search')}
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
