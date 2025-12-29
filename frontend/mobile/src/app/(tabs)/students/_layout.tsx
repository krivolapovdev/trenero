import { Stack } from 'expo-router';

export default function StudentsLayout() {
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
        name='[id]'
        options={{ headerShown: false }}
      />
      <Stack.Screen
        name='add-student'
        options={{ headerShown: false }}
      />
    </Stack>
  );
}
