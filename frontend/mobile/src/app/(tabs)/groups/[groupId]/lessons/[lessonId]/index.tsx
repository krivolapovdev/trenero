import { Redirect, useLocalSearchParams } from 'expo-router';

export default function Index() {
  const { groupId, lessonId } = useLocalSearchParams<{
    groupId: string;
    lessonId: string;
  }>();
  return (
    <Redirect href={`/(tabs)/groups/${groupId}/lessons/${lessonId}/update`} />
  );
}
