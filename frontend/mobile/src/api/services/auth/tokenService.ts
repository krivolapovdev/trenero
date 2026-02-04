import { api } from '@/src/api';
import type { paths } from '@/src/api/generated/openapi';

type RefreshRequest =
  paths['/api/v1/jwt/refresh']['post']['requestBody']['content']['application/json'];

type RefreshResponse =
  paths['/api/v1/jwt/refresh']['post']['responses'][200]['content']['*/*'];

export const tokenService = {
  async refreshTokens(refreshToken: string) {
    const body: RefreshRequest = {
      refreshToken
    };

    const { data } = await api.post<RefreshResponse>(
      `/api/v1/jwt/refresh`,
      body
    );

    return data;
  }
};
