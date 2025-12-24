import { gql } from '@apollo/client';
import { useMutation } from '@apollo/client/react';
import {
  GoogleSignin,
  isErrorWithCode,
  isSuccessResponse,
  statusCodes
} from '@react-native-google-signin/google-signin';
import type { SocialLoginInput } from '@/graphql/inputs';
import type { LoginPayload } from '@/graphql/types';
import { useAuthStore } from '@/stores/authStore';

const GOOGLE_LOGIN = gql`
    mutation ($input: SocialLoginInput!) {
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
`;

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

  const [googleLoginMutation, { loading }] = useMutation<
    { googleLogin: LoginPayload },
    { input: SocialLoginInput }
  >(GOOGLE_LOGIN);

  const signIn = async () => {
    if (loading) {
      return;
    }

    setErrorMessage(null);

    try {
      await GoogleSignin.hasPlayServices();
      const response = await GoogleSignin.signIn();

      if (!isSuccessResponse(response)) {
        throw new Error('Google Sign In failed');
      }

      const { idToken } = response.data;
      if (!idToken) {
        throw new Error('Failed to retrieve Google ID token');
      }

      const { data } = await googleLoginMutation({
        variables: { input: { idToken } }
      });

      const payload = data?.googleLogin;
      if (!payload) {
        throw new Error('Login failed: no data returned');
      }

      await setAuth(payload);
    } catch (error) {
      setErrorMessage(getGoogleErrorMessage(error));
    }
  };

  return { signIn, loading };
}
