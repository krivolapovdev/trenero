import dayjs from 'dayjs';
import { useRouter } from 'expo-router';
import { memo, useMemo } from 'react';
import type { components } from '@/src/api/generated/openapi';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { CustomCalendar } from './CustomCalendar';

type Props = {
  groupId: string;
  visitsWithLesson: components['schemas']['VisitWithLessonResponse'][];
};

export const VisitCalendar = memo(
  ({ groupId, visitsWithLesson }: Readonly<Props>) => {
    const router = useRouter();
    const theme = useAppTheme();

    const items = useMemo(
      () =>
        [...visitsWithLesson]
          .filter(value => value.visit.status !== 'UNMARKED')
          .map(item => {
            const status = item.visit.status;
            const type = item.visit.type;
            return {
              date: dayjs(item.lesson.date),
              textColor:
                status === 'PRESENT'
                  ? theme.colors.onSecondaryContainer
                  : theme.colors.onErrorContainer,
              selectedColor:
                status === 'PRESENT'
                  ? theme.colors.secondaryContainer
                  : theme.colors.errorContainer,
              dotColor: type === 'FREE' ? 'yellow' : undefined,
              status: status,
              type: type,
              lessonId: item.visit.lessonId
            };
          }),
      [visitsWithLesson, theme]
    );

    return (
      <CustomCalendar
        items={items}
        onDatePress={date => {
          const item = items.find(d => d.date.isSame(date));
          if (item) {
            router.push(`/(tabs)/groups/${groupId}/lessons/${item.lessonId}`);
          }
        }}
      />
    );
  }
);
