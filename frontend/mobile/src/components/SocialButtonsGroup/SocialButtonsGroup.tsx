import { useState } from 'react';
import { StyleSheet, View } from 'react-native';
import { Text } from 'react-native-paper';
import { SocialAuthButton } from '@/src/components/SocialButtonsGroup/SocialAuthButton';
import { useAppleSignIn } from '@/src/hooks/useAppleSignIn';
import { useGoogleSignIn } from '@/src/hooks/useGoogleSignIn';

export function SocialButtonsGroup() {
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const google = useGoogleSignIn(setErrorMessage);
  const apple = useAppleSignIn(setErrorMessage);
  const disabled = google?.loading || apple?.loading;

  return (
    <View style={styles.buttonsContainer}>
      {errorMessage && (
        <Text style={styles.errorMessage}>Error: {errorMessage}</Text>
      )}

      <SocialAuthButton
        label='Sign in with Apple'
        icon='apple'
        loading={apple.loading}
        onPress={async () => await apple.signIn()}
        disabled={disabled}
      />

      <SocialAuthButton
        label='Sign in with Google'
        icon='google'
        loading={google.loading}
        onPress={async () => await google.signIn()}
        disabled={disabled}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  errorMessage: {
    color: 'red',
    marginTop: 10
  },
  buttonsContainer: {
    width: '100%',
    gap: 16
  },
  buttonContent: {
    height: 52
  }
});
