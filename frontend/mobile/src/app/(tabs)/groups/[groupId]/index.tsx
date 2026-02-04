import { useLocalSearchParams, useRouter } from 'expo-router';
import { useEffect } from 'react';
import { useAsyncCallback } from 'react-async-hook';
import { useTranslation } from 'react-i18next';
import { Alert, RefreshControl, ScrollView } from 'react-native';
import { Divider, List, Text } from 'react-native-paper';
import { groupService } from '@/src/api/services/group/groupService';
import { LessonsCalendar } from '@/src/components/Calendar';
import { GroupCard } from '@/src/components/Card';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { useGroupsStore } from '@/src/stores/groupsStore';

export default function GroupByIdScreen() {
  const { groupId } = useLocalSearchParams<{ groupId: string }>();
  const theme = useAppTheme();
  const router = useRouter();
  const { t } = useTranslation();

  const recentGroups = useGroupsStore(state => state.recentGroups);
  const addGroup = useGroupsStore(state => state.addGroup);
  const removeGroup = useGroupsStore(state => state.removeGroup);
  const group = recentGroups.find(g => g.id === groupId);

  const {
    execute: fetchGroup,
    loading: groupLoading,
    error: fetchError
  } = useAsyncCallback(async () => {
    const data = await groupService.getDetails(groupId);
    addGroup(data);
    return data;
  });

  const {
    execute: deleteGroup,
    loading: mutationLoading,
    error: deleteError
  } = useAsyncCallback(() => groupService.delete(groupId));

  const handleDelete = () => {
    Alert.alert(t('deleteGroup'), t('deleteGroupConfirmation'), [
      { text: t('cancel'), style: 'cancel' },
      {
        text: t('delete'),
        style: 'destructive',
        onPress: () =>
          void deleteGroup()
            .then(() => removeGroup(groupId))
            .then(() => router.back())
      }
    ]);
  };

  useEffect(() => {
    if (!group) {
      void fetchGroup();
    }
  }, [group, fetchGroup]);

  useEffect(() => {
    if (deleteError) {
      Alert.alert(t('error'), deleteError.message);
    }
  }, [deleteError, t]);

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
            disabled:
              groupLoading ||
              mutationLoading ||
              group?.groupStudents.length === 0
          },
          {
            icon: 'account-edit',
            onPress: () => router.push(`/(tabs)/groups/${groupId}/update`),
            disabled: groupLoading || mutationLoading
          },
          {
            icon: 'trash-can',
            onPress: handleDelete,
            disabled: groupLoading || mutationLoading
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
            refreshing={groupLoading || mutationLoading}
            onRefresh={fetchGroup}
          />
        }
      >
        <OptionalErrorMessage error={fetchError?.message} />

        {group && (
          <>
            <GroupCard {...group} />

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
