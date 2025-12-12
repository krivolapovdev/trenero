import {
  GoogleSignin,
  GoogleSigninButton,
  isErrorWithCode,
  isSuccessResponse,
  type SignInResponse,
  statusCodes
} from '@react-native-google-signin/google-signin';
import { useState } from 'react';
import { Text, View } from 'react-native';

GoogleSignin.configure({
  webClientId: process.env.EXPO_PUBLIC_GOOGLE_WEB_CLIENT_ID,
  iosClientId: process.env.EXPO_PUBLIC_GOOGLE_IOS_CLIENT_ID,
  scopes: ['profile', 'email']
});

export function GoogleButton() {
  const [user, setUser] = useState<SignInResponse | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const signInWithGoogle = async () => {
    try {
      setIsLoading(true);
      setErrorMessage(null);

      await GoogleSignin.hasPlayServices();
      const response = await GoogleSignin.signIn();

      if (isSuccessResponse(response)) {
        setUser(response);
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
    }

    setIsLoading(false);
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
        color={GoogleSigninButton.Color.Light}
        onPress={signInWithGoogle}
        disabled={isLoading}
      />

      {user && (
        <Text style={{ color: 'white', marginTop: 10 }}>
          Logged in as: {JSON.stringify(user, null, 2)}
        </Text>
      )}
    </View>
  );
}
