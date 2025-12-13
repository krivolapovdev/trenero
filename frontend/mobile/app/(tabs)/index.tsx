import { Text, View } from 'react-native';
import { useThemeColor } from '@/hooks/useThemeColor';

export default function HomeScreen() {
  const textColor = useThemeColor({}, 'text');

  return (
    <View>
      <Text style={{ color: textColor }}>Main page</Text>
    </View>
  );
}
