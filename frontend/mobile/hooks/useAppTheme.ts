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
    const baseTheme = colorScheme === 'light' ? MD3LightTheme : MD3DarkTheme;
    const greenColor = colorScheme === 'light' ? '#DCEDC8' : '#33691E';

    return {
      ...baseTheme,
      colors: {
        ...baseTheme.colors,
        green: greenColor
      }
    };
  }, [colorScheme]);
};
