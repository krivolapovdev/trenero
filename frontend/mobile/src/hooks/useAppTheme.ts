import {useMemo} from 'react';
import {MD3LightTheme} from 'react-native-paper';
import type {MD3Theme} from 'react-native-paper/src/types';

type AppTheme = MD3Theme & {
  colors: MD3Theme['colors'] & {
    green: string;
  };
};

export const useAppTheme = (): AppTheme => {
  return useMemo(() => {
    const baseTheme = MD3LightTheme;
    const greenColor = '#9CCC65';

    return {
      ...baseTheme,
      colors: {
        ...baseTheme.colors,
        green: greenColor
      }
    };
  }, []);
};
