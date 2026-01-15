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
  attendances: NonNullable<GetStudentQuery['student']>['attendances'];
};

export const AttendanceCalendar = memo(
  ({ groupId, attendances }: Readonly<Props>) => {
    const router = useRouter();

    const [selectedDate, setSelectedDate] = useState<dayjs.Dayjs | null>(null);

    const items = useMemo(
      () =>
        [...attendances]
          .map(attendance => ({
            date: dayjs(attendance.lesson.startDateTime),
            color: attendance.present ? 'green' : '#fc975c',
            isPresent: attendance.present,
            lessonId: attendance.lesson.id
          }))
          .sort((a, b) => a.date.diff(b.date)),
      [attendances]
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
  }
);
