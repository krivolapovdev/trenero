import { useQueries } from '@tanstack/react-query';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert, RefreshControl, ScrollView } from 'react-native';
import { Divider, List, Text } from 'react-native-paper';
import { api } from '@/src/api';
import { LessonsCalendar } from '@/src/components/Calendar';
import { GroupCard } from '@/src/components/Card';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { useAppTheme } from '@/src/hooks/useAppTheme';

export default function GroupByIdScreen() {
  const { groupId } = useLocalSearchParams<{ groupId: string }>();
  const theme = useAppTheme();
  const router = useRouter();
  const { t } = useTranslation();

  const queries = useQueries({
    queries: [
      api.queryOptions('get', '/api/v1/groups/{groupId}', {
        params: {
          path: { groupId }
        }
      }),

      api.queryOptions('get', '/api/v1/groups/{groupId}/students', {
        params: {
          path: { groupId }
        }
      }),

      api.queryOptions('get', '/api/v1/groups/{groupId}/lessons', {
        params: {
          path: { groupId }
        }
      })
    ]
  });

  const group = queries[0]?.data;
  const groupStudents = queries[1]?.data;
  const groupLessons = queries[2]?.data;

  const queriesFetching = queries.some(q => q.isFetching);

  const { mutate: deleteGroup, isPending: mutationLoading } = api.useMutation(
    'delete',
    '/api/v1/groups/{groupId}',
    {
      onSuccess: router.back,

      onError: err => Alert.alert(t('error'), err)
    }
  );

  const handleDeletePress = () => {
    Alert.alert(t('deleteGroup'), t('deleteGroupConfirmation'), [
      { text: t('cancel'), style: 'cancel' },
      {
        text: t('delete'),
        style: 'destructive',
        onPress: () =>
          deleteGroup({
            params: {
              path: { groupId }
            }
          })
      }
    ]);
  };

  return (
    <>
      <CustomAppbar
        title={t('group')}
        leftActions={[
          {
            icon: 'arrow-left',
            onPress: () => router.back(),
            disabled: mutationLoading
          }
        ]}
        rightActions={[
          {
            icon: 'calendar-plus',
            onPress: () => router.push(`/groups/${groupId}/lessons/create`),
            disabled: queriesFetching || mutationLoading
          },
          {
            icon: 'account-edit',
            onPress: () => router.push(`/(tabs)/groups/${groupId}/update`),
            disabled: queriesFetching || mutationLoading
          },
          {
            icon: 'trash-can',
            onPress: handleDeletePress,
            disabled: queriesFetching || mutationLoading
          }
        ]}
      />

      <ScrollView
        contentContainerStyle={{ padding: 16, gap: 16 }}
        showsVerticalScrollIndicator={false}
        style={{
          flex: 1,
          backgroundColor: theme.colors.surfaceVariant
        }}
        refreshControl={
          <RefreshControl
            refreshing={queriesFetching || mutationLoading}
            onRefresh={() => Promise.all(queries.map(q => q.refetch()))}
          />
        }
      >
        {group && groupLessons && groupStudents && (
          <>
            k
            <GroupCard {...group} />
            <LessonsCalendar
              groupId={groupId}
              lessons={groupLessons}
            />
            {groupStudents.length > 0 && (
              <List.Section
                style={{
                  borderRadius: 16,
                  backgroundColor: theme.colors.surface
                }}
              >
                <List.Subheader>
                  <Text
                    variant='bodyLarge'
                    style={{ textAlign: 'center' }}
                  >
                    {t('students')}
                  </Text>
                </List.Subheader>

                <Divider />

                {groupStudents.map(student => (
                  <List.Item
                    key={student.fullName}
                    title={student.fullName}
                    onPress={() =>
                      router.push(`/(tabs)/students/${student.id}`)
                    }
                  />
                ))}
              </List.Section>
            )}
          </>
        )}
      </ScrollView>
    </>
  );
}
