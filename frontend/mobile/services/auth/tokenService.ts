import { api } from '@/services';
import type { JwtTokenResponse } from '@/services/auth/auth.types';

const baseURL = '/api/v1/tokens';

export const tokenService = {
  async refreshTokens(refreshToken: string) {
    const { data } = await api.post<JwtTokenResponse>(`${baseURL}/refresh`, {
      refreshToken
    });
    return data;
  }
};
