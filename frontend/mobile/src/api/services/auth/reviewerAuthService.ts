import { authApi } from '@/src/api';
import type { paths } from '@/src/api/generated/openapi';

type LoginResponse =
  paths['/api/v1/oauth2/google']['post']['responses'][200]['content']['*/*'];

export const reviewerAuthService = {
  loginAsReviewer: async () => {
    const { data } = await authApi.post<LoginResponse>('/auth/reviewer/login');
    return data;
  }
};
