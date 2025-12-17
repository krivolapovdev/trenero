import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import ErrorBoundary from 'react-native-error-boundary';
import { PaperProvider } from 'react-native-paper';
import { logError } from '@/helpers/logError';
import { useAppTheme } from '@/hooks/useAppTheme';

export default function RootLayout() {
  const theme = useAppTheme();

  return (
    <ErrorBoundary onError={logError}>
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
    </ErrorBoundary>
  );
}
