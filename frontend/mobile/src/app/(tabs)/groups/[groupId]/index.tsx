import { useMutation, useQuery } from '@apollo/client/react';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert, RefreshControl, ScrollView, View } from 'react-native';
import { Divider, List, Text } from 'react-native-paper';
import { LessonsCalendar } from '@/src/components/Calendar';
import { GroupCard } from '@/src/components/Card';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import { graphql } from '@/src/graphql/__generated__';
import { GET_GROUP } from '@/src/graphql/queries';
import { useAppTheme } from '@/src/hooks/useAppTheme';

const DELETE_GROUP = graphql(`
    mutation DeleteGroup($id: UUID!) {
        deleteGroup(id: $id) {
            id
        }
    }
`);

export default function GroupByIdScreen() {
  const { groupId } = useLocalSearchParams<{ groupId: string }>();
  const theme = useAppTheme();
  const router = useRouter();
  const { t } = useTranslation();

  const { data, loading, error, refetch } = useQuery(GET_GROUP, {
    variables: { id: groupId },
    fetchPolicy: 'cache-first'
  });

  const [deleteGroup, resultDeleteGroup] = useMutation(DELETE_GROUP, {
    variables: { id: groupId },

    update(cache, { data }) {
      if (!data?.deleteGroup) {
        return;
      }

      cache.evict({ id: cache.identify(data.deleteGroup) });
      cache.gc();
    },

    onCompleted: () => router.back(),

    onError: err => Alert.alert(t('error'), err.message)
  });

  const handleDeletePress = () => {
    Alert.alert(t('deleteGroup'), t('deleteGroupConfirmation'), [
      { text: t('cancel'), style: 'cancel' },
      {
        text: t('delete'),
        style: 'destructive',
        onPress: () => {
          void deleteGroup();
        }
      }
    ]);
  };

  const group = data?.group;

  return (
    <>
      <CustomAppbar
        title={t('group')}
        leftActions={[
          {
            icon: 'arrow-left',
            onPress: () => router.back(),
            disabled: resultDeleteGroup.loading
          }
        ]}
        rightActions={[
          {
            icon: 'calendar-plus',
            onPress: () => router.push(`/groups/${groupId}/lessons/create`),
            disabled: loading || resultDeleteGroup.loading
          },
          {
            icon: 'account-edit',
            onPress: () => router.push(`/(tabs)/groups/${groupId}/edit`),
            disabled: loading || resultDeleteGroup.loading
          },
          {
            icon: 'trash-can',
            onPress: () => handleDeletePress(),
            disabled: loading || resultDeleteGroup.loading
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
            refreshing={loading}
            onRefresh={refetch}
          />
        }
      >
        <OptionalErrorMessage error={error?.message} />

        {group && (
          <>
            <GroupCard {...group} />

            <LessonsCalendar lessons={group.lessons} />

            {group.students.length > 0 && (
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

                {group.students.map(student => (
                  <View key={student.fullName}>
                    <List.Item
                      title={student.fullName}
                      onPress={() => router.push(`/students/${student.id}`)}
                    />
                    <Divider />
                  </View>
                ))}
              </List.Section>
            )}
          </>
        )}
      </ScrollView>
    </>
  );
}
