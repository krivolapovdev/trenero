import { Image } from 'expo-image';
import { StyleSheet, useWindowDimensions, View } from 'react-native';
import { Divider, Text, useTheme } from 'react-native-paper';
import { SafeAreaView } from 'react-native-safe-area-context';
import { SocialButtonsGroup } from '@/components/SocialButtonsGroup';

export default function LoginScreen() {
  const { width, height } = useWindowDimensions();
  const theme = useTheme();

  return (
    <SafeAreaView
      style={[
        styles.safeArea,
        { backgroundColor: theme.colors.surfaceVariant }
      ]}
    >
      <View style={styles.container}>
        <View style={styles.content}>
          <View style={styles.logoContainer}>
            <Image
              style={{ width, height: height * 0.3 }}
              source={require('../../assets/images/tiny-people-carrying-key-to-open-padlock.svg')}
              contentFit='contain'
            />
          </View>
          <SocialButtonsGroup />
        </View>

        <View style={styles.bottomContainer}>
          <Divider style={styles.divider} />
          <Text
            variant='bodySmall'
            style={{
              color: theme.colors.onSurfaceVariant,
              textAlign: 'center'
            }}
          >
            By continuing, you agree to our Terms & Privacy Policy
          </Text>
        </View>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: { flex: 1 },
  container: { flex: 1, padding: 24 },
  content: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  logoContainer: { alignItems: 'center' },
  bottomContainer: { paddingBottom: 8 },
  divider: { width: '100%', marginBottom: 12 }
});
