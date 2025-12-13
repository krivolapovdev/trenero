import { Pressable, Text, View } from 'react-native';
import { useThemeColor } from '@/hooks/useThemeColor';

export function AppleButton() {
  const color = useThemeColor({}, 'text');

  return (
    <View>
      <Pressable>
        <Text style={{ color: color }}>Sign in with Apple</Text>
      </Pressable>
    </View>
  );
}
