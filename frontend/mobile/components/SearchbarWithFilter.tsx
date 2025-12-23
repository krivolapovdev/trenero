import { memo } from 'react';
import { StyleSheet, View } from 'react-native';
import { IconButton, Searchbar } from 'react-native-paper';
import { useAppTheme } from '@/hooks/useAppTheme';

const ELEMENT_SIZE = 56;

type SearchBarWithFilterProps = {
  value: string;
  onChange: (query: string) => void;
  onClear: () => void;
  onFilterPress: () => void;
};

export const SearchbarWithFilter = memo(
  ({ value, onChange, onClear, onFilterPress }: SearchBarWithFilterProps) => {
    const theme = useAppTheme();

    return (
      <View style={styles.container}>
        <Searchbar
          placeholder='Search by name'
          value={value}
          onChangeText={onChange}
          onClearIconPress={onClear}
          style={[styles.searchbar, { backgroundColor: theme.colors.surface }]}
        />

        <IconButton
          icon='filter'
          size={22}
          onPress={onFilterPress}
          style={[styles.filter, { backgroundColor: theme.colors.surface }]}
        />
      </View>
    );
  }
);

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    padding: 0,
    margin: 0
  },
  searchbar: {
    flex: 1,
    height: ELEMENT_SIZE,
    padding: 0,
    margin: 0
  },
  filter: {
    height: ELEMENT_SIZE,
    width: ELEMENT_SIZE,
    borderRadius: ELEMENT_SIZE / 2,
    padding: 0,
    margin: 0
  }
});
