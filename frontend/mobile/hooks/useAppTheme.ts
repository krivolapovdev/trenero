import { useMemo } from 'react';
import { useColorScheme } from 'react-native';
import { MD3DarkTheme, MD3LightTheme } from 'react-native-paper';

export const useAppTheme = () => {
  const colorScheme = useColorScheme();

  return useMemo(() => {
    if (colorScheme === 'light') {
      return {
        ...MD3LightTheme,
        colors: {
          ...MD3LightTheme.colors,
          green: '#DCEDC8'
        }
      };
    } else {
      return {
        ...MD3DarkTheme,
        colors: {
          ...MD3DarkTheme.colors,
          green: '#33691E'
        }
      };
    }
  }, [colorScheme]);
};
