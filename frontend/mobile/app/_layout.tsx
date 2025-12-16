import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { PaperProvider } from 'react-native-paper';
import { useAppTheme } from '@/hooks/useAppTheme';

export default function RootLayout() {
  const theme = useAppTheme();

  return (
    <PaperProvider theme={theme}>
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
