import { Image } from 'expo-image';
import { useState } from 'react';
import { StyleSheet, useWindowDimensions, View } from 'react-native';
import { Divider, Text } from 'react-native-paper';
import { SafeAreaView } from 'react-native-safe-area-context';
import { ConfirmDialog } from '@/src/components/dialogs';
import { SocialButtonsGroup } from '@/src/components/SocialButtonsGroup';
import { useAppTheme } from '@/src/hooks/useAppTheme';

export default function LoginScreen() {
  const [isTermsDialogVisible, setIsTermsDialogVisible] = useState(false);

  const { width, height } = useWindowDimensions();
  const theme = useAppTheme();

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
              onPress={() => setIsTermsDialogVisible(true)}
            >
              Terms & Privacy Policy
            </Text>
          </Text>
        </View>
      </View>

      {isTermsDialogVisible && (
        <ConfirmDialog
          visible={isTermsDialogVisible}
          title='Terms & Privacy Policy'
          onConfirm={() => setIsTermsDialogVisible(false)}
          onDismiss={() => setIsTermsDialogVisible(false)}
        >
          <Text
            variant='bodyMedium'
            style={{ textAlign: 'justify' }}
          >
            Terms of Service
            {'\n\n'}
            By accessing or using this application, you acknowledge that you
            have read, understood, and agree to be bound by these Terms of
            Service. The application is provided on an “as is” and “as
            available” basis, without warranties of any kind, whether express,
            implied, or statutory, including but not limited to implied
            warranties of merchantability, fitness for a particular purpose, and
            non-infringement.
            {'\n\n'}
            Privacy Policy
            {'\n\n'}
            We collect and process only the information necessary to provide and
            maintain the application. Personal data is not sold, rented, or
            otherwise disclosed to third parties except as required by law.
            Reasonable administrative, technical, and organizational measures
            are implemented to protect personal data from unauthorized access,
            use, or disclosure.
          </Text>
        </ConfirmDialog>
      )}
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
