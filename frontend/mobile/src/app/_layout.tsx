import { BottomSheetModalProvider } from '@gorhom/bottom-sheet';
import { QueryClientProvider } from '@tanstack/react-query';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import ErrorBoundary from 'react-native-error-boundary';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { PaperProvider } from 'react-native-paper';
import { queryClient } from '@/src/api';
import { logError } from '@/src/helpers/logError';
import { useAppTheme } from '@/src/hooks/useAppTheme';

export default function RootLayout() {
  const theme = useAppTheme();

  return (
    <ErrorBoundary onError={logError}>
      <QueryClientProvider client={queryClient}>
        <GestureHandlerRootView>
          <BottomSheetModalProvider>
            <PaperProvider theme={theme}>
              <StatusBar style='dark' />
              <Stack screenOptions={{ headerShown: false }}>
                <Stack.Screen
                  name='auth'
                  options={{ headerShown: false }}
                />

                <Stack.Screen
                  name='(tabs)'
                  options={{ headerShown: false }}
                />
              </Stack>
            </PaperProvider>
          </BottomSheetModalProvider>
        </GestureHandlerRootView>
      </QueryClientProvider>
    </ErrorBoundary>
  );
}
