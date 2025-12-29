import { Image } from 'expo-image';
import { useState } from 'react';
import { StyleSheet, useWindowDimensions, View } from 'react-native';
import { Divider, Text } from 'react-native-paper';
import { SafeAreaView } from 'react-native-safe-area-context';
import { AppBottomSheet } from '@/src/components/AppBottomSheet';
import { SocialButtonsGroup } from '@/src/components/SocialButtonsGroup';
import { TermsContent } from '@/src/components/TermsContent';
import { useAppTheme } from '@/src/hooks/useAppTheme';

export default function LoginScreen() {
  const theme = useAppTheme();
  const { width, height } = useWindowDimensions();
  const [isTermsVisible, setIsTermsVisible] = useState(false);

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
              source={require('@/src/assets/images/tiny-people-carrying-key-to-open-padlock.svg')}
              contentFit='contain'
            />
          </View>
          <SocialButtonsGroup />
        </View>

        <View style={styles.bottomContainer}>
          <Divider
            style={[styles.divider, { backgroundColor: theme.colors.outline }]}
          />
          <Text
            variant='bodySmall'
            style={{
              color: theme.colors.onSurfaceVariant,
              textAlign: 'center'
            }}
          >
            By continuing, you agree to our{' '}
            <Text
              variant='bodySmall'
              onPress={() => setIsTermsVisible(true)}
            >
              Terms & Privacy Policy
            </Text>
          </Text>
        </View>
      </View>

      <AppBottomSheet
        visible={isTermsVisible}
        onDismiss={() => setIsTermsVisible(false)}
      >
        <TermsContent />
      </AppBottomSheet>
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
