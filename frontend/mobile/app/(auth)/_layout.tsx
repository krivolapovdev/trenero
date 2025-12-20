import { Redirect, Stack } from 'expo-router';

import { useAuthStore } from '@/stores/authStore';

export default function AuthLayout() {
  const user = useAuthStore(state => state.user);

  if (user) {
    return <Redirect href='/(tabs)/(statistics)' />;
  }

  return (
    <Stack
      screenOptions={{
        headerShown: false
      }}
    >
      <Stack.Screen
        name='index'
        options={{ headerShown: false }}
      />
    </Stack>
  );
}
