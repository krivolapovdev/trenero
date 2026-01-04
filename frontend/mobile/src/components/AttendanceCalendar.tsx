import dayjs from 'dayjs';
import { memo, useCallback, useMemo, useState } from 'react';
import { View } from 'react-native';
import { Calendar } from 'react-native-calendars';
import { IconButton } from 'react-native-paper';
import type { GetStudentQuery } from '@/src/graphql/__generated__/graphql';
import { useAppTheme } from '@/src/hooks/useAppTheme';

type Props = {
  attendances: NonNullable<GetStudentQuery['student']>['attendances'];
};

export const AttendanceCalendar = memo(({ attendances }: Readonly<Props>) => {
  const theme = useAppTheme();
  const [currentMonth, setCurrentMonth] = useState(dayjs());

  const markedDates = useMemo(
    () =>
      Object.fromEntries(
        attendances.map(attendance => [
          dayjs(attendance.createdAt).format('YYYY-MM-DD'),
          {
            selected: true,
            selectedColor: attendance.present ? '#fc975c' : '#00adf5'
          }
        ])
      ),
    [attendances]
  );

  const goPrevMonth = useCallback(() => {
    setCurrentMonth(prev => prev.subtract(1, 'month'));
  }, []);

  const goNextMonth = useCallback(() => {
    setCurrentMonth(prev => prev.add(1, 'month'));
  }, []);

  return (
    <View style={{ borderRadius: 16, backgroundColor: theme.colors.surface }}>
      <Calendar
        initialDate={currentMonth.format('YYYY-MM-DD')}
        style={{
          borderRadius: 16,
          backgroundColor: theme.colors.surface
        }}
        markedDates={markedDates}
        hideExtraDays={true}
        hideArrows={true}
        monthFormat={'MM/yyyy'}
        theme={{
          backgroundColor: theme.colors.surface,
          calendarBackground: theme.colors.surface
        }}
      />

      <View
        style={{
          display: 'flex',
          flexDirection: 'row',
          alignItems: 'center',
          justifyContent: 'flex-end'
        }}
      >
        <IconButton
          icon='chevron-left'
          onPress={goPrevMonth}
        />

        <IconButton
          icon='chevron-right'
          disabled={currentMonth.isSame(new Date(), 'month')}
          onPress={goNextMonth}
        />
      </View>
    </View>
  );
});
