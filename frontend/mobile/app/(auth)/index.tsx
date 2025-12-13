import { LinearGradient } from 'expo-linear-gradient';
import { StyleSheet, useColorScheme } from 'react-native';
import { AppleButton } from '@/components/AppleButton';
import { GoogleButton } from '@/components/GoogleButton';
import { Logo } from '@/components/Logo';

export default function LoginScreen() {
  const colorScheme = useColorScheme();

  const colors =
    colorScheme === 'light'
      ? (['#a6c1ee', '#209cff'] as const)
      : (['#000000', '#3F51B5'] as const);

  return (
    <LinearGradient
      colors={colors}
      style={styles.container}
      start={{ x: 0.5, y: 0 }}
      end={{ x: 0.5, y: 1 }}
    >
      <Logo />
      <AppleButton />
      <GoogleButton />
    </LinearGradient>
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
