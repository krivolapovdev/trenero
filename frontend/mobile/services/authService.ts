import axios from 'axios';
import { api } from '@/services/index';
import { useAuthStore } from '@/stores/authStore';

const baseURL = '/api/v1/oauth2';

type AuthResponse = {
  user: {
    id: string;
    email: string;
  };
  jwtToken: {
    accessToken: string;
  };
};

export const authService = {
  async authenticateWithGoogle(idToken: string) {
    try {
      const { data } = await api.post<AuthResponse>(`${baseURL}/google`, {
        idToken
      });

      const setAuth = useAuthStore.getState().setAuth;
      setAuth(data.user, data.jwtToken.accessToken);

      return data;
    } catch (error: unknown) {
      if (axios.isAxiosError(error)) {
        const message =
          error.response?.data?.message ??
          error.message ??
          'Failed to authenticate with backend';

        console.error('Google authentication failed:', message);
        throw new Error(message);
      }

      console.error('Google authentication failed:', error);
      throw new Error('Failed to authenticate with backend');
    }
  },

  async logout() {
    try {
      await api.post(`${baseURL}/logout`);
    } catch (error: unknown) {
      console.error('Failed to logout:', error);
    } finally {
      useAuthStore.getState().logout();
    }
  }
};
