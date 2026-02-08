import dayjs from 'dayjs';
import { useRouter } from 'expo-router';
import { memo, useMemo, useState } from 'react'; // Add useState
import { Text } from 'react-native-paper'; // Import both
import type { components } from '@/src/api/generated/openapi';
import { SurfaceCard } from '@/src/components/SurfaceCard';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { CalendarControls, CustomCalendar } from './CustomCalendar';

type Props = {
  groupId: string;
  lessons: components['schemas']['LessonResponse'][];
};

export const LessonsCalendar = memo(({ groupId, lessons }: Readonly<Props>) => {
  const router = useRouter();
  const theme = useAppTheme();

  const [currentMonth, setCurrentMonth] = useState(dayjs());

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
    <SurfaceCard>
      <Text
        variant='bodyLarge'
        style={{ textAlign: 'center', marginTop: 8 }}
      >
        {currentMonth.format('MMMM YYYY')}
      </Text>

      <CustomCalendar
        currentMonth={currentMonth}
        items={items}
        onDatePress={date => {
          const item = items.find(d => d.date.isSame(date));
          if (item) {
            router.push(`/(tabs)/groups/${groupId}/lessons/${item.lessonId}`);
          }
        }}
      />
      <CalendarControls
        currentMonth={currentMonth}
        onPrev={() => setCurrentMonth(p => p.subtract(1, 'month'))}
        onNext={() => setCurrentMonth(p => p.add(1, 'month'))}
      />
    </SurfaceCard>
  );
});
