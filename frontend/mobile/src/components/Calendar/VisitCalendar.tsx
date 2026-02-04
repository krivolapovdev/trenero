import dayjs from 'dayjs';
import { useRouter } from 'expo-router';
import { memo, useMemo, useState } from 'react';
import { List } from 'react-native-paper';
import type { components } from '@/src/api/generated/openapi';
import { CustomBottomSheet } from '@/src/components/BottomSheet';
import { SurfaceCard } from '@/src/components/SurfaceCard';
import { VisitStatusColor, VisitStatusIcon } from '@/src/types/visit';
import { CustomCalendar } from './CustomCalendar';

type Props = {
  groupId: string;
  visitsWithLesson: components['schemas']['VisitWithLessonResponse'][];
};

export const VisitCalendar = memo(
  ({ groupId, visitsWithLesson }: Readonly<Props>) => {
    const router = useRouter();

    const [selectedDate, setSelectedDate] = useState<dayjs.Dayjs | null>(null);

    const items = useMemo(
      () =>
        [...visitsWithLesson]
          .filter(value => value.visit.status !== 'UNMARKED')
          .map(item => {
            const status = item.visit.status;
            return {
              date: dayjs(item.lesson.startDateTime),
              color: VisitStatusColor[status],
              status: status,
              lessonId: item.visit.lessonId
            };
          })
          .sort((a, b) => a.date.diff(b.date)),
      [visitsWithLesson]
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
                  key={item.lessonId}
                  style={{ padding: 0 }}
                >
                  <List.Item
                    title={item.date.format('HH:mm')}
                    right={() => (
                      <List.Icon
                        icon={VisitStatusIcon[item.status]}
                        color={VisitStatusColor[item.status]}
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
  }
);
