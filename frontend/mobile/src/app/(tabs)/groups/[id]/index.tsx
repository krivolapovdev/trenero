import { useMutation, useQuery } from '@apollo/client/react';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { Alert, RefreshControl, ScrollView, View } from 'react-native';
import { Divider, List, Text } from 'react-native-paper';
import { LessonsCalendar } from '@/src/components/Calendar';
import { GroupCard } from '@/src/components/Card';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import { graphql } from '@/src/graphql/__generated__';
import type { GetGroupQuery } from '@/src/graphql/__generated__/graphql';
import { GET_GROUP } from '@/src/graphql/queries';
import { useAppTheme } from '@/src/hooks/useAppTheme';

const buildSubtitle = (group: NonNullable<GetGroupQuery['group']>) =>
  [
    group.defaultPrice && `Default price: ${group.defaultPrice}`,
    group.note && `Note: ${group.note}`
  ]
    .filter(Boolean)
    .join('\n\n');

const DELETE_GROUP = graphql(`
    mutation DeleteGroup($id: UUID!) {
        deleteGroup(id: $id) {
            id
        }
    }
`);

export default function GroupByIdScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const theme = useAppTheme();
  const router = useRouter();

  const { data, loading, error, refetch } = useQuery(GET_GROUP, {
    variables: { id },
    fetchPolicy: 'cache-and-network'
  });

  const [deleteGroup, resultDeleteGroup] = useMutation(DELETE_GROUP, {
    variables: { id },

    update(cache, { data }) {
      if (!data?.deleteGroup) {
        return;
      }

      cache.evict({ id: cache.identify(data.deleteGroup) });
      cache.gc();
    },

    onCompleted: () => {
      router.back();
    },

    onError: err => {
      Alert.alert('Error', err.message);
    }
  });

  const handleEditPress = () => {
    console.log('Edit pressed');
  };

  const handleDeletePress = () => {
    Alert.alert(
      'Delete Group',
      `Are you sure you want to delete ${group?.name || 'this group'}?`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: () => {
            void deleteGroup();
          }
        }
      ]
    );
  };

  const group = data?.group;

  return (
    <>
      <CustomAppbar
        title='Group'
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
            onPress: () => router.push(`/groups/${id}/lessons/create`),
            disabled: loading || resultDeleteGroup.loading
          },
          {
            icon: 'account-edit',
            onPress: () => handleEditPress(),
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
            <GroupCard
              subtitle={buildSubtitle(group)}
              {...group}
            />

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
                    Students
                  </Text>
                </List.Subheader>

                <Divider />

                {group.students.map(student => (
                  <View key={student.fullName}>
                    <List.Item title={student.fullName} />
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
