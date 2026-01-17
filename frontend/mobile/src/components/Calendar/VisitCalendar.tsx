import dayjs from 'dayjs';
import { useRouter } from 'expo-router';
import { nanoid } from 'nanoid/non-secure';
import { memo, useMemo, useState } from 'react';
import { List } from 'react-native-paper';
import { CustomBottomSheet } from '@/src/components/BottomSheet';
import { SurfaceCard } from '@/src/components/SurfaceCard';
import type { GetStudentQuery } from '@/src/graphql/__generated__/graphql';
import { CustomCalendar } from './CustomCalendar';

type Props = {
  groupId: string;
  visits: NonNullable<GetStudentQuery['student']>['visits'];
};

export const VisitCalendar = memo(({ groupId, visits }: Readonly<Props>) => {
  const router = useRouter();

  const [selectedDate, setSelectedDate] = useState<dayjs.Dayjs | null>(null);

  const items = useMemo(
    () =>
      [...visits]
        .map(visit => ({
          date: dayjs(visit.lesson.startDateTime),
          color: visit.present ? 'green' : '#fc975c',
          isPresent: visit.present,
          lessonId: visit.lesson.id
        }))
        .sort((a, b) => a.date.diff(b.date)),
    [visits]
  );

  return (
    <>
      <CustomCalendar
        items={items}
        onDatePress={setSelectedDate}
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
                      color={item.isPresent ? 'green' : 'orange'}
                    />
                  )}
                  onPress={() => {
                    setSelectedDate(null);
                    router.push(
                      `/(tabs)/groups/${groupId}/lessons/${item.lessonId}`
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
