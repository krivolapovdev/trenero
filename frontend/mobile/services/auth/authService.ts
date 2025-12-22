import axios from 'axios';
import { api } from '@/services';
import type { AuthResponse } from '@/services/auth/auth.types';
import { useAuthStore } from '@/stores/authStore';

const baseURL = '/api/v1/oauth2';

export const authService = {
  async authenticateWithGoogle(idToken: string) {
    try {
      const { data } = await api.post<AuthResponse>(`${baseURL}/google`, {
        idToken
      });

      await useAuthStore
        .getState()
        .setAuth(
          { id: data.id, email: data.email },
          data.accessToken,
          data.refreshToken
        );

      return data;
    } catch (error: unknown) {
      const message = axios.isAxiosError(error)
        ? (error.response?.data?.message ?? error.message)
        : 'Failed to authenticate with backend';

      console.error('Google authentication failed:', error);
      throw new Error(message || 'Failed to authenticate with backend');
    }
  }
};
