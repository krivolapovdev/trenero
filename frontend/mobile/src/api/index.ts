import createFetchClient, { type Middleware } from 'openapi-fetch';
import createClient from 'openapi-react-query';
import type { paths } from '@/src/api/generated/openapi';
import { useAuthStore } from '@/src/stores/authStore';

const BASE_URL = process.env.EXPO_PUBLIC_API_URL ?? 'http://10.0.2.2:8080';

const authClient = createFetchClient<paths>({
  baseUrl: BASE_URL
});
const fetchClient = createFetchClient<paths>({
  baseUrl: BASE_URL
});

let refreshPromise: Promise<string | null> | null = null;

const authMiddleware: Middleware = {
  async onRequest({ request }) {
    const token = useAuthStore.getState().accessToken;
    if (token) {
      request.headers.set('Authorization', `Bearer ${token}`);
    }
    return request;
  },

  async onResponse({ request, response }) {
    if (response.status !== 401 && response.status !== 403) {
      return response;
    }

    const store = useAuthStore.getState();
    const refreshToken = await store.getRefreshToken();
    const user = store.user;

    if (!refreshToken || !user) {
      return response;
    }

    refreshPromise ??= refreshAccessToken().finally(() => {
      refreshPromise = null;
    });

    const newAccessToken = await refreshPromise;

    if (!newAccessToken) {
      return response;
    }

    const retryRequest = request.clone();
    retryRequest.headers.set('Authorization', `Bearer ${newAccessToken}`);
    return fetch(retryRequest);
  }
};

fetchClient.use(authMiddleware);

export const api = createClient(fetchClient);

async function refreshAccessToken(): Promise<string | null> {
  const store = useAuthStore.getState();
  const refreshToken = await store.getRefreshToken();
  const user = store.user;

  if (!refreshToken || !user) {
    return null;
  }

  const { data: jwtTokens, error } = await authClient.POST(
    '/api/v1/jwt/refresh',
    {
      body: { refreshToken }
    }
  );

  if (error || !jwtTokens) {
    await store.logout();
    return null;
  }

  await store.setAuth({
    user,
    jwtTokens
  });

  return jwtTokens.accessToken;
}
