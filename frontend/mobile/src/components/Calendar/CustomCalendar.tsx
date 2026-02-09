import dayjs from 'dayjs';
import { memo, useCallback, useMemo, useState } from 'react';
import { View } from 'react-native';
import { Calendar } from 'react-native-calendars';
import { IconButton } from 'react-native-paper';
import { useAppTheme } from '@/src/hooks/useAppTheme';

type MarkedDay = {
  date: dayjs.Dayjs;
  textColor?: string;
  selectedColor?: string;
  dotColor?: string;
};

type Props = {
  items: MarkedDay[];
  onDatePress: (date: dayjs.Dayjs) => void;
};

export const CustomCalendar = memo(
  ({ items, onDatePress }: Readonly<Props>) => {
    const theme = useAppTheme();
    const [currentMonth, setCurrentMonth] = useState(dayjs());

    const markedDates = useMemo(
      () =>
        Object.fromEntries(
          items.map(item => [
            item.date.format('YYYY-MM-DD'),
            {
              selected: true,
              selectedColor: item.selectedColor,
              marked: Boolean(item.dotColor),
              dotColor: item.dotColor,
              disabled: false,
              customStyles: {
                text: {
                  color: item.textColor ?? 'white'
                }
              }
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
          markingType='custom'
          initialDate={currentMonth.format('YYYY-MM-DD')}
          style={{
            borderRadius: 16,
            backgroundColor: theme.colors.surface
          }}
          firstDay={1}
          markedDates={markedDates}
          disableAllTouchEventsForDisabledDays={true}
          disabledByDefault={true}
          hideExtraDays={true}
          hideArrows={true}
          monthFormat='MM/yyyy'
          onDayPress={date => onDatePress(dayjs(date.dateString))}
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
  }
);
