import dayjs from 'dayjs';
import { memo, useMemo } from 'react';
import { StyleSheet, View } from 'react-native';
import { Calendar } from 'react-native-calendars';
import { IconButton } from 'react-native-paper';
import { useAppTheme } from '@/src/hooks/useAppTheme';

type MarkedDay = {
  date: dayjs.Dayjs;
  textColor?: string;
  selectedColor?: string;
  dotColor?: string;
};

type CalendarProps = {
  items: MarkedDay[];
  currentMonth: dayjs.Dayjs;
  onDatePress: (date: dayjs.Dayjs) => void;
};

type ControlsProps = {
  currentMonth: dayjs.Dayjs;
  onPrev: () => void;
  onNext: () => void;
  disableNext?: boolean;
};

export const CustomCalendar = memo(
  ({ items, currentMonth, onDatePress }: Readonly<CalendarProps>) => {
    const theme = useAppTheme();

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

    return (
      <View style={{ borderRadius: 16, backgroundColor: theme.colors.surface }}>
        <Calendar
          markingType='custom'
          key={currentMonth.format('YYYY-MM')}
          current={currentMonth.format('YYYY-MM-DD')}
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
          renderHeader={() => null}
          onDayPress={date => onDatePress(dayjs(date.dateString))}
          theme={{
            backgroundColor: theme.colors.surface,
            calendarBackground: theme.colors.surface
          }}
        />
      </View>
    );
  }
);

export const CalendarControls = memo(
  ({ onPrev, onNext, disableNext }: Readonly<ControlsProps>) => (
    <View style={styles.controlsContainer}>
      <IconButton
        icon='chevron-left'
        onPress={onPrev}
      />

      <IconButton
        icon='chevron-right'
        disabled={disableNext}
        onPress={onNext}
      />
    </View>
  )
);

const styles = StyleSheet.create({
  controlsContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'flex-end',
    marginTop: 8
  }
});
