import { Redirect, Tabs } from 'expo-router';

import { useAuthStore } from '@/stores/authStore';

export default function AuthLayout() {
  const user = useAuthStore(state => state.user);

  if (user) {
    return <Redirect href='/(tabs)' />;
  }

  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarStyle: { display: 'none' }
      }}
    >
      <Tabs.Screen name='index' />
    </Tabs>
  );
}
