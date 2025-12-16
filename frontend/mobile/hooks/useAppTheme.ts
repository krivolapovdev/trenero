import { useColorScheme } from 'react-native';
import { MD3DarkTheme, MD3LightTheme } from 'react-native-paper';

export function useAppTheme() {
  const colorScheme = useColorScheme();

  return colorScheme === 'light'
    ? {
        ...MD3LightTheme,
        colors: {
          ...MD3LightTheme.colors,
          green40: '#ceef85',
          yellow90: '#ffe088'
        }
      }
    : {
        ...MD3DarkTheme,
        colors: {
          ...MD3DarkTheme.colors,
          green40: '#131f00',
          yellow90: '#765b01'
        }
      };
}
