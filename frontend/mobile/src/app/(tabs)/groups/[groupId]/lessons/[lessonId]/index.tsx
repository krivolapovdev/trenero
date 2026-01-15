import { useMutation, useQuery } from '@apollo/client/react';
import dayjs from 'dayjs';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { Alert, ScrollView } from 'react-native';
import { List, Text } from 'react-native-paper';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { LoadingSpinner } from '@/src/components/LoadingSpinner';
import { SurfaceCard } from '@/src/components/SurfaceCard';
import { graphql } from '@/src/graphql/__generated__';
import { GET_LESSON } from '@/src/graphql/queries';
import { useAppTheme } from '@/src/hooks/useAppTheme';

const DELETE_LESSON = graphql(`
    mutation DeleteLesson($id: UUID!) {
        deleteLesson(id: $id) {
            id
        }
    }
`);

export default function LessonByIdScreen() {
  const router = useRouter();
  const theme = useAppTheme();
  const { t } = useTranslation();
  const { groupId, lessonId } = useLocalSearchParams<{
    groupId: string;
    lessonId: string;
  }>();

  const { data, loading: queryLoading } = useQuery(GET_LESSON, {
    variables: { id: lessonId }
  });

  const [deleteLesson, { loading: mutationLoading }] = useMutation(
    DELETE_LESSON,
    {
      variables: { id: lessonId },

      update(cache, { data }) {
        if (!data?.deleteLesson) {
          return;
        }

        cache.evict({ id: cache.identify(data.deleteLesson) });
        cache.gc();
      },

      onCompleted: () => router.back(),

      onError: err => Alert.alert(t('error'), err.message)
    }
  );

  const handleDeletePress = () => {
    Alert.alert(t('deleteLesson'), t('deleteLessonConfirmation'), [
      { text: t('cancel'), style: 'cancel' },
      {
        text: t('delete'),
        style: 'destructive',
        onPress: () => void deleteLesson()
      }
    ]);
  };

  return (
    <>
      <CustomAppbar
        title={t('lesson')}
        leftActions={[{ icon: 'arrow-left', onPress: router.back }]}
        rightActions={[
          {
            icon: 'account-edit',
            onPress: () =>
              router.push(`/(tabs)/groups/${groupId}/lessons/${lessonId}/edit`),
            disabled: queryLoading || mutationLoading
          },
          {
            icon: 'trash-can',
            onPress: handleDeletePress,
            disabled: queryLoading || mutationLoading
          }
        ]}
      />

      <ScrollView
        contentContainerStyle={{ padding: 16, gap: 16 }}
        style={{ flex: 1, backgroundColor: theme.colors.surfaceVariant }}
      >
        {queryLoading && <LoadingSpinner />}

        {!queryLoading && data?.lesson && (
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
                {dayjs(data.lesson.startDateTime).format('DD/MM/YYYY')}
              </Text>

              <Text variant='bodyLarge'>
                {dayjs(data.lesson.startDateTime).format('HH:mm')}
              </Text>
            </SurfaceCard>

            <SurfaceCard style={{ padding: 0 }}>
              {data.lesson.attendances.map(a => (
                <List.Item
                  key={a.student.id}
                  title={a.student.fullName}
                  right={() => (
                    <List.Icon
                      icon='circle-medium'
                      color={a.present ? 'green' : 'orange'}
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
