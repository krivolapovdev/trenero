import { memo } from 'react';
import { View } from 'react-native';
import { List } from 'react-native-paper';
import { useAppTheme } from '@/src/hooks/useAppTheme';

type Props = {
  title: string;
  items: { id: string; name: string }[];
  selectedItem?: string | null;
  onSelect: (item: string) => void;
  expanded: boolean;
  onPress: () => void;
};

export const FilterAccordion = memo(
  ({ title, items, selectedItem, onSelect, expanded, onPress }: Props) => {
    const theme = useAppTheme();

    return (
      <View style={{ borderRadius: 12, overflow: 'hidden' }}>
        <List.Accordion
          title={title}
          description={items.find(value => value.id === selectedItem)?.name}
          expanded={expanded}
          onPress={onPress}
          style={{ backgroundColor: theme.colors.surface }}
          titleStyle={{ color: theme.colors.onSurface }}
          descriptionStyle={{ color: theme.colors.primary }}
        >
          <View style={{ backgroundColor: theme.colors.surface }}>
            {items.map(item => (
              <List.Item
                key={item.id}
                title={item.name}
                onPress={() => onSelect(item.id)}
                right={props => (
                  <List.Icon
                    {...props}
                    icon={item.id === selectedItem ? 'check' : 'blank'}
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
  }
);
