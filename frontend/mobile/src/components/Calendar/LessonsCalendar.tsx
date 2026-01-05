import dayjs from 'dayjs';
import { memo, useMemo } from 'react';
import type { GetGroupQuery } from '@/src/graphql/__generated__/graphql';
import { CustomCalendar } from './CustomCalendar';

type Props = {
  lessons: NonNullable<GetGroupQuery['group']>['lessons'];
};

export const LessonsCalendar = memo(({ lessons }: Readonly<Props>) => {
  const items = useMemo(
    () =>
      lessons.map(lesson => ({
        date: dayjs(lesson.startDateTime)
      })),
    [lessons]
  );

  return <CustomCalendar items={items} />;
});
