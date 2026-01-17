import { Stack } from 'expo-router';

export default function LessonByIdLayout() {
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
