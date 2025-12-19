import { useLocalSearchParams } from 'expo-router';
import { View } from 'react-native';
import { Text } from 'react-native-paper';

export default function StudentByIdScreen() {
  const { id } = useLocalSearchParams();

  return (
    <View>
      <Text>StudentByIdScreen</Text>
      <Text>{id}</Text>
    </View>
  );
}
