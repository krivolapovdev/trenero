import { Redirect, useLocalSearchParams } from 'expo-router';

export default function Index() {
  const { studentId } = useLocalSearchParams<{ studentId: string }>();
  return <Redirect href={`/(tabs)/students/${studentId}/payments/create`} />;
}
