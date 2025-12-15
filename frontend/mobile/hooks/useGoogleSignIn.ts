import {
  GoogleSignin,
  isErrorWithCode,
  isSuccessResponse,
  statusCodes
} from '@react-native-google-signin/google-signin';
import { useState } from 'react';
import { authService } from '@/services/authService';

export function useGoogleSignIn(
  setErrorMessage: (message: string | null) => void
) {
  const [loading, setLoading] = useState<boolean>(false);

  const signIn = async () => {
    if (loading) {
      return;
    }

    try {
      setLoading(true);
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
      setLoading(false);
    }
  };

  return { signIn, loading };
}
