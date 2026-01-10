import { Redirect, useLocalSearchParams } from 'expo-router';

export default function Index() {
  const { id } = useLocalSearchParams<{ id: string }>();
  return <Redirect href={`/(tabs)/students/${id}/payments/create`} />;
}
