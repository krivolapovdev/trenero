import { memo } from 'react';
import { View } from 'react-native';
import { List } from 'react-native-paper';
import { useAppTheme } from '@/hooks/useAppTheme';

type FilterAccordionProps<T> = {
  title: string;
  items: readonly T[];
  selectedItem: T | undefined;
  onSelect: (item: T) => void;
  expanded: boolean;
  onPress: () => void;
  displayValue?: string;
};

const FilterAccordionComponent = <T extends string>({
  title,
  items,
  selectedItem,
  onSelect,
  expanded,
  onPress,
  displayValue
}: FilterAccordionProps<T>) => {
  const theme = useAppTheme();

  return (
    <View style={{ borderRadius: 12, overflow: 'hidden' }}>
      <List.Accordion
        title={title}
        description={displayValue || selectedItem}
        expanded={expanded}
        onPress={onPress}
        style={{ backgroundColor: theme.colors.surface }}
        titleStyle={{ color: theme.colors.onSurface }}
        descriptionStyle={{ color: theme.colors.primary }}
      >
        <View style={{ backgroundColor: theme.colors.surface }}>
          {items.map(item => (
            <List.Item
              key={item}
              title={item}
              onPress={() => onSelect(item)}
              right={props => (
                <List.Icon
                  {...props}
                  icon={item === selectedItem ? 'check' : 'blank'}
                />
              )}
              titleStyle={{
                paddingLeft: 16,
                includeFontPadding: false,
                lineHeight: 20
              }}
            />
          ))}
        </View>
      </List.Accordion>
    </View>
  );
};

export const FilterAccordion = memo(
  FilterAccordionComponent
) as typeof FilterAccordionComponent;
