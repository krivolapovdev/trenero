import { Redirect, useLocalSearchParams } from 'expo-router';

export default function Index() {
  const { groupId } = useLocalSearchParams<{ groupId: string }>();
  return <Redirect href={`/(tabs)/groups/${groupId}/lessons/create`} />;
}
