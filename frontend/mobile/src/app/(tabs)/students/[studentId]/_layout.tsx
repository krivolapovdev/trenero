import { Stack } from 'expo-router';

export default function StudentByIdLayout() {
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

      <Stack.Screen
        name='update'
        options={{ headerShown: false }}
      />
    </Stack>
  );
}
