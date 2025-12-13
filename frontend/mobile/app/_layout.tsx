import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useColorScheme } from 'react-native';
import { MD3DarkTheme, MD3LightTheme, PaperProvider } from 'react-native-paper';

export default function RootLayout() {
  const colorScheme = useColorScheme();

  const paperTheme =
    colorScheme === 'light' ? { ...MD3LightTheme } : { ...MD3DarkTheme };

  return (
    <PaperProvider theme={paperTheme}>
      <StatusBar style='auto' />
      <Stack screenOptions={{ headerShown: false }}>
        <Stack.Screen
          name='(auth)'
          options={{ headerShown: false }}
        />
        <Stack.Screen
          name='(tabs)'
          options={{ headerShown: false }}
        />
      </Stack>
    </PaperProvider>
  );
}
