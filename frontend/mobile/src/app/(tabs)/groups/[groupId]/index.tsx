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

  const {
    data: group,
    isPending: groupPending,
    refetch
  } = api.useQuery('get', '/api/v1/groups/{groupId}/details', {
    params: {
      path: {
        groupId
      }
    }
  });

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
            disabled: groupPending || mutationLoading
          },
          {
            icon: 'account-edit',
            onPress: () => router.push(`/(tabs)/groups/${groupId}/update`),
            disabled: groupPending || mutationLoading
          },
          {
            icon: 'trash-can',
            onPress: handleDeletePress,
            disabled: groupPending || mutationLoading
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
            refreshing={groupPending || mutationLoading}
            onRefresh={refetch}
          />
        }
      >
        {group && (
          <>
            <GroupCard
              {...group}
              studentsCount={group.groupStudents.length}
            />

            <LessonsCalendar
              groupId={groupId}
              lessons={group.groupLessons}
            />

            {group.groupStudents.length > 0 && (
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

                {group.groupStudents.map(student => (
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
