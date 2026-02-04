import axios, { type AxiosError, type InternalAxiosRequestConfig } from 'axios';
import { useAuthStore } from '@/src/stores/authStore';

export const api = axios.create({
  baseURL: process.env.EXPO_PUBLIC_API_URL ?? 'http://10.0.2.2:8080',
  timeout: __DEV__ ? 10_000 : 20_000,
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
      const { tokenService } = await import(
        '@/src/api/services/auth/tokenService'
      );
      const jwtTokens = await tokenService.refreshTokens(refreshToken);

      await useAuthStore.getState().setAuth({ user, jwtTokens });

      originalRequest.headers.Authorization = `Bearer ${jwtTokens.accessToken}`;

      return api(originalRequest);
    } catch (error) {
      console.error(`Failed to refresh tokens: ${error}`);

      await useAuthStore.getState().logout();

      return Promise.reject(error);
    }
  }
);
