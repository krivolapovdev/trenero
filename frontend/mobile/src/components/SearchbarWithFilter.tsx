import { memo } from 'react';
import { StyleSheet, View } from 'react-native';
import { IconButton, Searchbar } from 'react-native-paper';
import { useAppTheme } from '@/src/hooks/useAppTheme';

const ELEMENT_SIZE = 56;

type SearchBarWithFilterProps = {
  value: string;
  onChange: (query: string) => void;
  onClearIconPress: () => void;
  onFilterPress: () => void;
  hasActiveFilters?: boolean;
};

export const SearchbarWithFilter = memo(
  ({
    value,
    onChange,
    onClearIconPress,
    onFilterPress,
    hasActiveFilters
  }: SearchBarWithFilterProps) => {
    const theme = useAppTheme();

    return (
      <View style={styles.container}>
        <Searchbar
          placeholder='Search by name'
          value={value}
          onChangeText={onChange}
          onClearIconPress={onClearIconPress}
          style={[styles.searchbar, { backgroundColor: theme.colors.surface }]}
        />

        <View style={styles.filterContainer}>
          <IconButton
            icon='filter'
            size={22}
            onPress={onFilterPress}
            style={[styles.filter, { backgroundColor: theme.colors.surface }]}
          />
          {hasActiveFilters && (
            <View
              style={[styles.dot, { backgroundColor: theme.colors.error }]}
            />
          )}
        </View>
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
  filterContainer: {
    width: ELEMENT_SIZE,
    height: ELEMENT_SIZE,
    justifyContent: 'center',
    alignItems: 'center'
  },
  filter: {
    height: ELEMENT_SIZE,
    width: ELEMENT_SIZE,
    borderRadius: ELEMENT_SIZE / 2,
    padding: 0,
    margin: 0
  },
  dot: {
    position: 'absolute',
    top: 0,
    right: 8,
    width: 10,
    height: 10,
    borderRadius: 5
  }
});
