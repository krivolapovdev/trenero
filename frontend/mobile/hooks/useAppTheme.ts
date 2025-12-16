import { useMemo } from 'react';
import { useColorScheme } from 'react-native';
import { MD3DarkTheme, MD3LightTheme } from 'react-native-paper';
import type { MD3Theme } from 'react-native-paper/src/types';

type AppTheme = MD3Theme & {
  colors: MD3Theme['colors'] & {
    green: string;
  };
};

export const useAppTheme = (): AppTheme => {
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
