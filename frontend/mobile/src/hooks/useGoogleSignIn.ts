import {
  GoogleSignin,
  isErrorWithCode,
  isSuccessResponse,
  statusCodes
} from '@react-native-google-signin/google-signin';
import { useTranslation } from 'react-i18next';
import { Alert } from 'react-native';
import { api } from '@/src/api';
import { useAuthStore } from '@/src/stores/authStore';

GoogleSignin.configure({
  webClientId: process.env.EXPO_PUBLIC_GOOGLE_WEB_CLIENT_ID,
  iosClientId: process.env.EXPO_PUBLIC_GOOGLE_IOS_CLIENT_ID,
  scopes: ['profile', 'email']
});

const getGoogleErrorMessage = (error: unknown): string => {
  if (isErrorWithCode(error)) {
    switch (error.code) {
      case statusCodes.IN_PROGRESS:
        return 'Sign in already in progress';
      case statusCodes.PLAY_SERVICES_NOT_AVAILABLE:
        return 'Play Services not available';
      case statusCodes.SIGN_IN_CANCELLED:
        return 'Sign in cancelled';
      default:
        return `Google Error: ${error.code}`;
    }
  }

  return error instanceof Error
    ? error.message
    : 'An unexpected error occurred';
};

export function useGoogleSignIn() {
  const setAuth = useAuthStore(state => state.setAuth);
  const { t } = useTranslation();

  const { mutateAsync, isPending } = api.useMutation(
    'post',
    '/api/v1/oauth2/google',
    {
      onError: err => Alert.alert(t('error'), err)
    }
  );

  const signIn = async () => {
    await GoogleSignin.hasPlayServices().catch(error => {
      throw new Error(getGoogleErrorMessage(error));
    });

    const response = await GoogleSignin.signIn().catch(error => {
      throw new Error(getGoogleErrorMessage(error));
    });

    if (!isSuccessResponse(response)) {
      throw new Error('Google Sign In failed');
    }

    const { idToken } = response.data;
    if (!idToken) {
      throw new Error('Failed to retrieve Google ID token');
    }

    const data = await mutateAsync({
      body: {
        token: idToken
      }
    });

    if (!data) {
      throw new Error('Login failed: no data returned');
    }

    await setAuth(data);

    return data;
  };

  return {
    signIn,
    isPending
  };
}
