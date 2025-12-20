import { Image } from 'expo-image';
import { useState } from 'react';
import { StyleSheet, useWindowDimensions, View } from 'react-native';
import { Divider, Text } from 'react-native-paper';
import { SafeAreaView } from 'react-native-safe-area-context';
import { ScrollableDialog } from '@/components/ScrollableDialog';
import { SocialButtonsGroup } from '@/components/SocialButtonsGroup';
import { useAppTheme } from '@/hooks/useAppTheme';

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
              source={require('../../assets/images/tiny-people-carrying-key-to-open-padlock.svg')}
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
              style={{ color: theme.colors.primary }}
              onPress={() => setIsTermsDialogVisible(true)}
            >
              Terms & Privacy Policy
            </Text>
          </Text>
        </View>
      </View>

      {isTermsDialogVisible && (
        <ScrollableDialog
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
            By using this application, you agree to comply with these Terms of
            Service. The service is provided “as is” without warranties of any
            kind.
            {'\n\n'}
            Privacy Policy
            {'\n\n'}
            We collect only the information necessary to provide the service. We
            do not sell your personal data and take reasonable steps to protect
            it.
          </Text>
        </ScrollableDialog>
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
