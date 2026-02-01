import createFetchClient from 'openapi-fetch';
import createClient, { type Middleware } from 'openapi-fetch';
import type { paths } from '@/src/api/generated/openapi';
import { useAuthStore } from '@/src/stores/authStore';

const BASE_URL = process.env.EXPO_PUBLIC_API_URL ?? 'http://10.0.2.2:8080';

let refreshPromise: Promise<string | null> | null = null;

type CustomRequest = Request & {
  _bodyInit?: BodyInit;
  _bodyText?: string;
};

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

    const headers = new Headers(request.headers);
    headers.set('Authorization', `Bearer ${newAccessToken}`);

    const requestInit: RequestInit = {
      method: request.method,
      headers: headers
    };

    if (request.method !== 'GET' && request.method !== 'HEAD') {
      const castedRequest = request as CustomRequest;
      requestInit.body = castedRequest._bodyText ?? castedRequest._bodyInit;
    }

    return fetch(request.url, requestInit);
  }
};

export const api = createClient<paths>({
  baseUrl: BASE_URL,
  cache: 'no-cache'
});

api.use(authMiddleware);

const authClient = createFetchClient<paths>({
  baseUrl: BASE_URL
});

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
