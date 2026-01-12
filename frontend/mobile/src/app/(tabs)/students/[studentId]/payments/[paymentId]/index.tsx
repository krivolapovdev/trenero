import { Redirect, useLocalSearchParams } from 'expo-router';

export default function Index() {
  const { studentId, paymentId } = useLocalSearchParams<{
    studentId: string;
    paymentId: string;
  }>();

  return (
    <Redirect
      href={`/(tabs)/students/${studentId}/payments/${paymentId}/edit`}
    />
  );
}
