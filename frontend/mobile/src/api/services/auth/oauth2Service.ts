import { api } from '@/src/api';
import type { paths } from '@/src/api/generated/openapi';

type GoogleLoginRequest =
  paths['/api/v1/oauth2/google']['post']['requestBody']['content']['application/json'];

type LoginResponse =
  paths['/api/v1/oauth2/google']['post']['responses'][200]['content']['*/*'];

export const oauth2Service = {
  async googleLogin(token: string) {
    const body: GoogleLoginRequest = {
      token
    };

    const { data } = await api.post<LoginResponse>(
      '/api/v1/oauth2/google',
      body
    );

    return data;
  }
};
