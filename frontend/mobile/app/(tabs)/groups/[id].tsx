import { useLocalSearchParams } from 'expo-router';
import { Text } from 'react-native-paper';
import { CustomAppbar } from '@/components/CustomAppbar';

export default function StudentByIdScreen() {
  const { id } = useLocalSearchParams();

  return (
    <>
      <CustomAppbar title='Group' />
      <Text>{id}</Text>
    </>
  );
}
