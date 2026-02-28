import { useAsyncCallback } from 'react-async-hook';
import { loginAsReviewer } from '@/src/api/services/auth/reviewerAuthService';
import { useAuthStore } from '@/src/stores/authStore';

export function useReviewerSignIn() {
  const setAuth = useAuthStore(state => state.setAuth);

  const {
    execute: signIn,
    loading: isLoading,
    error
  } = useAsyncCallback(async (key: string) => {
    const loginData = await loginAsReviewer(key);
    await setAuth(loginData);
  });

  return {
    signIn,
    isLoading,
    error
  };
}
