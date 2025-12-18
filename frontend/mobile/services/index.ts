import axios, { type AxiosError, type InternalAxiosRequestConfig } from 'axios';
import { tokenService } from '@/services/auth/tokenService';
import { useAuthStore } from '@/stores/authStore';

export const api = axios.create({
  baseURL: 'http://10.0.2.2:8080',
  timeout: 10_000,
  withCredentials: true,
  headers: {
    'Content-Type': 'application/json'
  }
});

api.interceptors.request.use(config => {
  const accessToken = useAuthStore.getState().accessToken;

  if (accessToken) {
    config.headers.Authorization = `Bearer ${accessToken}`;
  }

  return config;
});

api.interceptors.response.use(
  response => response,
  async (error: AxiosError) => {
    const originalRequest = error.config as InternalAxiosRequestConfig & {
      _retry?: boolean;
    };

    const user = useAuthStore.getState().user;
    const refreshToken = await useAuthStore.getState().getRefreshToken();

    const isAuthError =
      error.response?.status === 401 || error.response?.status === 403;
    const canRetry = !originalRequest._retry && refreshToken && user;

    if (!isAuthError || !canRetry) {
      console.error(`Failed to make request: ${error}`);
      return Promise.reject(error);
    }

    originalRequest._retry = true;

    try {
      const tokens = await tokenService.refreshTokens(refreshToken);

      await useAuthStore
        .getState()
        .setAuth(user, tokens.accessToken, tokens.refreshToken);

      originalRequest.headers.Authorization = `Bearer ${tokens.accessToken}`;

      return api(originalRequest);
    } catch (error) {
      console.error(`Failed to refresh tokens: ${error}`);

      await useAuthStore.getState().logout();

      return Promise.reject(error);
    }
  }
);
