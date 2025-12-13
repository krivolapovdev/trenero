import { StyleSheet, View } from 'react-native';
import { AppleButton } from '@/components/AppleButton';
import { GoogleButton } from '@/components/GoogleButton';
import { Logo } from '@/components/Logo';
import { useThemeColor } from '@/hooks/useThemeColor';

export default function LoginScreen() {
  const backgroundColor = useThemeColor({}, 'background');

  return (
    <View style={[styles.container, { backgroundColor: backgroundColor }]}>
      <Logo />
      <AppleButton />
      <GoogleButton />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    gap: 50
  }
});
