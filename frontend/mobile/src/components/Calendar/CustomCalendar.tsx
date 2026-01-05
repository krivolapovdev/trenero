import dayjs from 'dayjs';
import { memo, useCallback, useMemo, useState } from 'react';
import { View } from 'react-native';
import { Calendar } from 'react-native-calendars';
import { IconButton } from 'react-native-paper';
import { useAppTheme } from '@/src/hooks/useAppTheme';

type MarkedDay = {
  date: dayjs.Dayjs;
  color?: string;
};

type Props = {
  items: MarkedDay[];
};

export const CustomCalendar = memo(({ items }: Readonly<Props>) => {
  const theme = useAppTheme();
  const [currentMonth, setCurrentMonth] = useState(dayjs());

  const markedDates = useMemo(
    () =>
      Object.fromEntries(
        items.map(item => [
          item.date.format('YYYY-MM-DD'),
          {
            selected: true,
            selectedColor: item.color ?? '#00adf5'
          }
        ])
      ),
    [items]
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
          disabled={currentMonth.isSame(dayjs(), 'month')}
          onPress={goNextMonth}
        />
      </View>
    </View>
  );
});
