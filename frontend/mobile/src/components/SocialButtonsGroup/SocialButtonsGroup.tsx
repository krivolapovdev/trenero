import { useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { Alert, StyleSheet, View } from 'react-native';
import { SocialAuthButton } from '@/src/components/SocialButtonsGroup/SocialAuthButton';
import { useGoogleSignIn } from '@/src/hooks/useGoogleSignIn';

export function SocialButtonsGroup() {
  const { t } = useTranslation();

  const google = useGoogleSignIn();
  const disabled = google?.isLoading;

  useEffect(() => {
    if (google.error) {
      Alert.alert(t('error'), google.error.message);
    }
  }, [google.error, t]);

  return (
    <View style={styles.buttonsContainer}>
      {/*<SocialAuthButton*/}
      {/*  label={t('signInWithApple')}*/}
      {/*  icon='apple'*/}
      {/*  loading={apple.loading}*/}
      {/*  onPress={async () => await apple.signIn()}*/}
      {/*  disabled={disabled}*/}
      {/*/>*/}

      <SocialAuthButton
        label={t('signInWithGoogle')}
        icon='google'
        loading={google.isLoading}
        onPress={async () => {
          await google.signIn();
        }}
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
