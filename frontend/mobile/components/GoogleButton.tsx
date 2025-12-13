import {
  GoogleSignin,
  GoogleSigninButton,
  isErrorWithCode,
  isSuccessResponse,
  statusCodes
} from '@react-native-google-signin/google-signin';
import { useState } from 'react';
import { Text, useColorScheme, View } from 'react-native';
import { authService } from '@/services/authService';

GoogleSignin.configure({
  webClientId: process.env.EXPO_PUBLIC_GOOGLE_WEB_CLIENT_ID,
  iosClientId: process.env.EXPO_PUBLIC_GOOGLE_IOS_CLIENT_ID,
  scopes: ['profile', 'email']
});

export function GoogleButton() {
  const colorScheme = useColorScheme();

  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const signInWithGoogle = async () => {
    try {
      setIsLoading(true);
      setErrorMessage(null);

      await GoogleSignin.hasPlayServices();
      const response = await GoogleSignin.signIn();

      if (isSuccessResponse(response)) {
        const { data } = response;
        const googleIdToken = data.idToken;

        if (!googleIdToken) {
          setErrorMessage('Google ID token is missing');
          return;
        }

        await authService.authenticateWithGoogle(googleIdToken);
      } else {
        setErrorMessage('Google Sign In failed');
      }

      setIsLoading(false);
    } catch (error) {
      if (isErrorWithCode(error)) {
        switch (error.code) {
          case statusCodes.IN_PROGRESS:
            setErrorMessage('Google Sign In is in progress');
            break;
          case statusCodes.PLAY_SERVICES_NOT_AVAILABLE:
            setErrorMessage('Play Services are not available');
            break;
          default:
            setErrorMessage(error.code);
        }
      } else {
        setErrorMessage('Something went wrong');
      }
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <View>
      {errorMessage && (
        <Text style={{ color: 'red', marginTop: 10 }}>
          Error: {errorMessage}
        </Text>
      )}

      <GoogleSigninButton
        size={GoogleSigninButton.Size.Wide}
        color={
          colorScheme === 'light'
            ? GoogleSigninButton.Color.Light
            : GoogleSigninButton.Color.Dark
        }
        onPress={signInWithGoogle}
        disabled={isLoading}
      />
    </View>
  );
}
