import dayjs from 'dayjs';
import { useRouter } from 'expo-router';
import { nanoid } from 'nanoid/non-secure';
import { memo, useMemo, useState } from 'react';
import { List } from 'react-native-paper';
import { CustomBottomSheet } from '@/src/components/BottomSheet';
import { SurfaceCard } from '@/src/components/SurfaceCard';
import type { GetGroupQuery } from '@/src/graphql/__generated__/graphql';
import { CustomCalendar } from './CustomCalendar';

type Props = {
  groupId: string;
  lessons: NonNullable<GetGroupQuery['group']>['lessons'];
};

export const LessonsCalendar = memo(({ groupId, lessons }: Readonly<Props>) => {
  const router = useRouter();

  const [selectedDate, setSelectedDate] = useState<dayjs.Dayjs | null>(null);

  const items = useMemo(
    () =>
      [...lessons]
        .map(lesson => ({
          date: dayjs(lesson.startDateTime),
          lessonId: lesson.id
        }))
        .sort((a, b) => a.date.diff(b.date)),
    [lessons]
  );

  return (
    <>
      <CustomCalendar
        items={items}
        onDatePress={date => setSelectedDate(date)}
      />

      <CustomBottomSheet
        visible={
          Boolean(selectedDate) &&
          items.some(item => item.date.isSame(selectedDate, 'day'))
        }
        onDismiss={() => setSelectedDate(null)}
      >
        <List.Section style={{ gap: 10 }}>
          <SurfaceCard style={{ padding: 0 }}>
            <List.Item title={selectedDate?.format('DD/MM/YYYY')} />
          </SurfaceCard>

          {items
            .filter(item => item.date.isSame(selectedDate, 'day'))
            .map(item => (
              <SurfaceCard
                key={nanoid()}
                style={{ padding: 0 }}
              >
                <List.Item
                  title={item.date.format('HH:mm')}
                  right={() => (
                    <List.Icon
                      icon='circle-medium'
                      color='#00adf5'
                    />
                  )}
                  onPress={() => {
                    setSelectedDate(null);
                    router.push(
                      `/(tabs)/groups/${groupId}/lessons/${item.lessonId}/edit`
                    );
                  }}
                />
              </SurfaceCard>
            ))}
        </List.Section>
      </CustomBottomSheet>
    </>
  );
});
