import { useMutation } from '@apollo/client/react';
import {
  GoogleSignin,
  isErrorWithCode,
  isSuccessResponse,
  statusCodes
} from '@react-native-google-signin/google-signin';
import { graphql } from '@/src/graphql/__generated__';
import { useAuthStore } from '@/src/stores/authStore';

GoogleSignin.configure({
  webClientId: process.env.EXPO_PUBLIC_GOOGLE_WEB_CLIENT_ID,
  iosClientId: process.env.EXPO_PUBLIC_GOOGLE_IOS_CLIENT_ID,
  scopes: ['profile', 'email']
});

const GOOGLE_LOGIN = graphql(`
    mutation GoogleLogin($input: SocialLoginInput!) {
        googleLogin(input: $input) {
            user {
                id
                email
            }
            jwtTokens {
                accessToken
                refreshToken
            }
        }
    }
`);

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

export function useGoogleSignIn(
  setErrorMessage: (message: string | null) => void
) {
  const setAuth = useAuthStore(state => state.setAuth);
  const [googleLoginMutation, { loading }] = useMutation(GOOGLE_LOGIN);

  const signIn = async () => {
    if (loading) {
      return;
    }

    setErrorMessage(null);

    try {
      await GoogleSignin.hasPlayServices();
      const response = await GoogleSignin.signIn();

      if (!isSuccessResponse(response)) {
        setErrorMessage('Google Sign In failed');
        return;
      }

      const { idToken } = response.data;
      if (!idToken) {
        setErrorMessage('Failed to retrieve Google ID token');
        return;
      }

      const { data } = await googleLoginMutation({
        variables: { input: { idToken } }
      });

      const payload = data?.googleLogin;
      if (!payload) {
        setErrorMessage('Login failed: no data returned');
        return;
      }

      await setAuth(payload);
    } catch (error) {
      setErrorMessage(getGoogleErrorMessage(error));
    }
  };

  return { signIn, loading };
}
