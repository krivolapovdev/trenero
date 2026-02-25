import axios, { type AxiosError, type InternalAxiosRequestConfig } from 'axios';
import { useAuthStore } from '@/src/stores/authStore';

const axiosConfig = {
  baseURL: process.env.EXPO_PUBLIC_API_URL ?? 'http://10.0.2.2:8080',
  timeout: __DEV__ ? 10_000 : 20_000,
  withCredentials: true,
  headers: {
    'Content-Type': 'application/json'
  }
};

export const api = axios.create(axiosConfig);
export const authApi = axios.create(axiosConfig);

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

    if (!originalRequest || !error.response) {
      throw error;
    }

    const { status } = error.response;
    const user = useAuthStore.getState().user;
    const refreshToken = await useAuthStore.getState().getRefreshToken();

    const isAuthError = status === 401 || status === 403;
    if (!isAuthError || originalRequest._retry || !refreshToken || !user) {
      throw error;
    }

    originalRequest._retry = true;

    try {
      const { refreshTokens } = await import(
        '@/src/api/services/auth/tokenService'
      );

      const jwtTokens = await refreshTokens(refreshToken);

      await useAuthStore.getState().setAuth({ user, jwtTokens });

      originalRequest.headers.Authorization = `Bearer ${jwtTokens.accessToken}`;

      return api(originalRequest);
    } catch (error) {
      console.error(`Failed to refresh tokens: ${error}`);

      await useAuthStore.getState().logout();

      throw error;
    }
  }
);
