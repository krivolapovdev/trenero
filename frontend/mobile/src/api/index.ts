import createFetchClient from 'openapi-fetch';
import createClient from 'openapi-react-query';
import type { paths } from '@/src/api/generated/openapi';
import { useAuthStore } from '@/src/stores/authStore';

const fetchClient = createFetchClient<paths>({
  baseUrl: process.env.EXPO_PUBLIC_API_URL ?? 'http://10.0.2.2:8080',

  fetch: async (request: Request) => {
    const headers = new Headers(request.headers);
    headers.set('Content-Type', 'application/json');

    const token = useAuthStore.getState().accessToken;
    if (token) {
      headers.set('Authorization', `Bearer ${token}`);
    }

    const newRequest = new Request(request, { headers });

    return fetch(newRequest);
  }
});

export const api = createClient(fetchClient);

//
// api.interceptors.response.use(
//     response => response,
//     async (error: AxiosError) => {
//       const originalRequest = error.config as InternalAxiosRequestConfig & {
//         _retry?: boolean;
//       };
//
//       const user = useAuthStore.getState().user;
//       const refreshToken = await useAuthStore.getState().getRefreshToken();
//
//       const isAuthError =
//           error.response?.status === 401 || error.response?.status === 403;
//       const canRetry = !originalRequest._retry && refreshToken && user;
//
//       if (!isAuthError || !canRetry) {
//         console.error(`Failed to make request: ${error}`);
//         return Promise.reject(error);
//       }
//
//       originalRequest._retry = true;
//
//       try {
//         const { tokenService } = await import('./auth/tokenService');
//         const tokens = await tokenService.refreshTokens(refreshToken);
//
//         await useAuthStore
//             .getState()
//             .setAuth(user, tokens.accessToken, tokens.refreshToken);
//
//         originalRequest.headers.Authorization = `Bearer ${tokens.accessToken}`;
//
//         return api(originalRequest);
//       } catch (error) {
//         console.error(`Failed to refresh tokens: ${error}`);
//
//         await useAuthStore.getState().logout();
//
//         return Promise.reject(error);
//       }
//     }
// );
