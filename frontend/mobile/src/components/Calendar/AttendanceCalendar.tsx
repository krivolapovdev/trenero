import dayjs from 'dayjs';
import { memo, useMemo } from 'react';
import type { GetStudentQuery } from '@/src/graphql/__generated__/graphql';
import { CustomCalendar } from './CustomCalendar';

type Props = {
  attendances: NonNullable<GetStudentQuery['student']>['attendances'];
};

export const AttendanceCalendar = memo(({ attendances }: Readonly<Props>) => {
  const items = useMemo(
    () =>
      attendances.map(attendance => ({
        date: dayjs(attendance.createdAt),
        color: attendance.present ? '#fc975c' : '#00adf5'
      })),
    [attendances]
  );

  return <CustomCalendar items={items} />;
});
