import { SetContextLink } from '@apollo/client/link/context';
import { useAuthStore } from '@/stores/authStore';

export const authLink = new SetContextLink(prevContext => {
  const accessToken = useAuthStore.getState().accessToken;

  return {
    ...prevContext,
    headers: {
      ...prevContext.headers,
      ...(accessToken && {
        Authorization: `Bearer ${accessToken}`
      })
    }
  };
});
