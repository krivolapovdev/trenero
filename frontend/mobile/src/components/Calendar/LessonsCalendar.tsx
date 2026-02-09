import dayjs from 'dayjs';
import { useRouter } from 'expo-router';
import { memo, useMemo } from 'react';
import type { components } from '@/src/api/generated/openapi';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { CustomCalendar } from './CustomCalendar';

type Props = {
  groupId: string;
  lessons: components['schemas']['LessonResponse'][];
};

export const LessonsCalendar = memo(({ groupId, lessons }: Readonly<Props>) => {
  const router = useRouter();
  const theme = useAppTheme();

  const items = useMemo(
    () =>
      [...lessons].map(lesson => ({
        date: dayjs(lesson.date),
        lessonId: lesson.id,
        textColor: theme.colors.onSecondaryContainer,
        selectedColor: theme.colors.secondaryContainer
      })),
    [lessons, theme]
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
});
