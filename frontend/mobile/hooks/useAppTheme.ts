import { useColorScheme } from 'react-native';
import { MD3DarkTheme, MD3LightTheme } from 'react-native-paper';

export function useAppTheme() {
  const colorScheme = useColorScheme();

  return colorScheme === 'light'
    ? {
        ...MD3LightTheme,
        colors: {
          ...MD3LightTheme.colors,
          green: '#DCEDC8'
        }
      }
    : {
        ...MD3DarkTheme,
        colors: {
          ...MD3DarkTheme.colors,
          green: '#33691E'
        }
      };
}
