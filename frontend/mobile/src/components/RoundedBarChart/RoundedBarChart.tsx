import type dayjs from 'dayjs';
import { nanoid } from 'nanoid/non-secure';
import { useMemo } from 'react';
import { Pressable, StyleSheet, View } from 'react-native';
import { Divider, Text } from 'react-native-paper';
import { BarItem } from '@/src/components/RoundedBarChart/BarItem';
import { useAppTheme } from '@/src/hooks/useAppTheme';

type ChartData = {
  date: dayjs.Dayjs;
  value: number;
};

type Props = {
  data: ChartData[];
  selectedBar: dayjs.Dayjs;
  setSelectedBar: (date: dayjs.Dayjs) => void;
};

export const RoundedBarChart = ({
  data,
  selectedBar,
  setSelectedBar
}: Readonly<Props>) => {
  const theme = useAppTheme();

  const normalizedData = useMemo(() => {
    const maxValue = Math.max(...data.map(item => item.value));

    return data.map(item => ({
      ...item,
      value: maxValue <= 0 ? 0 : (item.value / maxValue) * 100
    }));
  }, [data]);

  return (
    <View style={[styles.container, { backgroundColor: theme.colors.surface }]}>
      <View style={styles.chartArea}>
        {normalizedData.map(item => (
          <View
            key={nanoid()}
            style={[styles.barContainer, { width: `${100 / data.length}%` }]}
          >
            <Pressable onPress={() => setSelectedBar(item.date)}>
              <BarItem
                value={item.value}
                isSelected={item.date.isSame(selectedBar, 'month')}
              />
            </Pressable>

            <Divider
              style={{ backgroundColor: theme.colors.outline, width: '100%' }}
            />

            <Text style={styles.label}>{item.date.format('MMM')}</Text>
          </View>
        ))}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    padding: 16,
    marginTop: 16,
    alignItems: 'center',
    justifyContent: 'center'
  },
  chartArea: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'space-between',
    width: '100%',
    flex: 1,
    minHeight: 200
  },
  barContainer: {
    alignItems: 'center'
  },
  bar: {
    width: 35,
    borderTopLeftRadius: 99,
    borderTopRightRadius: 99
  },
  label: {
    marginTop: 8
  }
});
