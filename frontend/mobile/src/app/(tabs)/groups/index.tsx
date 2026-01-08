import { useQuery } from '@apollo/client/react';
import { LegendList, type LegendListRef } from '@legendapp/list';
import { useScrollToTop } from '@react-navigation/native';
import { useRouter } from 'expo-router';
import { useCallback, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Searchbar } from 'react-native-paper';
import { GroupCard } from '@/src/components/Card';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import type { GetGroupsQuery } from '@/src/graphql/__generated__/graphql';
import { GET_GROUPS } from '@/src/graphql/queries';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { useFilteredGroups } from '@/src/hooks/useFilteredGroups';

export default function GroupsScreen() {
  const theme = useAppTheme();
  const router = useRouter();
  const { t } = useTranslation();

  const [searchQuery, setSearchQuery] = useState<string>('');

  const listRef = useRef<LegendListRef | null>(null);
  useScrollToTop(listRef);

  const { loading, data, error, refetch } = useQuery(GET_GROUPS, {
    fetchPolicy: 'cache-first'
  });

  const filteredGroups = useFilteredGroups(data?.groups ?? [], searchQuery);

  const fetchGroups = useCallback(() => {
    setSearchQuery('');
    refetch();
  }, [refetch]);

  const renderItem = useCallback(
    ({ item }: { item: GetGroupsQuery['groups'][number] }) => (
      <GroupCard {...item} />
    ),
    []
  );

  return (
    <>
      <CustomAppbar
        title={t('groups')}
        mode={'center-aligned'}
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
        refreshing={loading}
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
            <OptionalErrorMessage error={error?.message} />
          </>
        }
      />
    </>
  );
}
