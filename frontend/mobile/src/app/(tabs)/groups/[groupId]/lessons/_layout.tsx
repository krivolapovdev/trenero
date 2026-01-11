import { Stack } from 'expo-router';

export default function LessonsLayout() {
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
        name='create'
        options={{ headerShown: false }}
      />
    </Stack>
  );
}
