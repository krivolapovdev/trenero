import { useQueries } from '@tanstack/react-query';
import dayjs from 'dayjs';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert, RefreshControl, ScrollView } from 'react-native';
import { List, Text } from 'react-native-paper';
import { api } from '@/src/api';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { SurfaceCard } from '@/src/components/SurfaceCard';
import { useAppTheme } from '@/src/hooks/useAppTheme';

export default function LessonByIdScreen() {
  const router = useRouter();
  const theme = useAppTheme();
  const { t } = useTranslation();
  const { groupId, lessonId } = useLocalSearchParams<{
    groupId: string;
    lessonId: string;
  }>();

  const queries = useQueries({
    queries: [
      api.queryOptions('get', '/api/v1/lessons/{lessonId}', {
        params: { path: { lessonId } }
      }),

      api.queryOptions('get', '/api/v1/lessons/{lessonId}/visits', {
        params: { path: { lessonId } }
      }),

      api.queryOptions('get', '/api/v1/groups/{groupId}/students', {
        params: { path: { groupId } }
      }),

      api.queryOptions('get', '/api/v1/students')
    ]
  });

  const lesson = queries[0]?.data;
  const lessonVisits = queries[1]?.data ?? [];
  const groupStudents = queries[2]?.data ?? [];
  const allStudents = queries[3]?.data ?? [];

  const queriesFetching = queries.some(q => q.isFetching);

  const { mutate: deleteLesson, isPending: deleteLessonPending } =
    api.useMutation('delete', `/api/v1/lessons/{lessonId}`, {
      onSuccess: router.back,
      onError: err => Alert.alert(t('error'), err)
    });

  const handleDeletePress = () => {
    Alert.alert(t('deleteLesson'), t('deleteLessonConfirmation'), [
      { text: t('cancel'), style: 'cancel' },
      {
        text: t('delete'),
        style: 'destructive',
        onPress: () =>
          deleteLesson({
            params: {
              path: {
                lessonId
              }
            }
          })
      }
    ]);
  };

  const isLoading = queriesFetching || deleteLessonPending;

  return (
    <>
      <CustomAppbar
        title={t('lesson')}
        leftActions={[
          {
            icon: 'arrow-left',
            onPress: router.back,
            disabled: deleteLessonPending
          }
        ]}
        rightActions={[
          {
            icon: 'account-edit',
            onPress: () =>
              router.push(
                `/(tabs)/groups/${groupId}/lessons/${lessonId}/update`
              ),
            disabled: isLoading
          },
          {
            icon: 'trash-can',
            onPress: handleDeletePress,
            disabled: isLoading
          }
        ]}
      />

      <ScrollView
        contentContainerStyle={{ padding: 16, gap: 16 }}
        style={{ flex: 1, backgroundColor: theme.colors.surfaceVariant }}
        refreshControl={
          <RefreshControl
            refreshing={queriesFetching}
            onRefresh={() => Promise.all(queries.map(q => q.refetch()))}
          />
        }
      >
        {lesson && lessonVisits && groupStudents && allStudents && (
          <>
            <SurfaceCard
              style={{
                flex: 1,
                flexDirection: 'row',
                justifyContent: 'space-between',
                alignItems: 'center'
              }}
            >
              <Text variant='bodyLarge'>
                {dayjs(lesson.startDateTime).format('DD/MM/YYYY')}
              </Text>

              <Text variant='bodyLarge'>
                {dayjs(lesson.startDateTime).format('HH:mm')}
              </Text>
            </SurfaceCard>

            <SurfaceCard style={{ padding: 0 }}>
              {lessonVisits.map(visit => (
                <List.Item
                  key={visit.id}
                  title={
                    allStudents.find(student => visit.studentId === student.id)
                      ?.fullName ?? ''
                  }
                  right={() => (
                    <List.Icon
                      icon='circle-medium'
                      color={visit.present ? 'green' : 'orange'}
                    />
                  )}
                />
              ))}
            </SurfaceCard>
          </>
        )}
      </ScrollView>
    </>
  );
}
