import { authApi } from '@/src/api';
import type { paths } from '@/src/api/generated/openapi';

type LoginResponse =
  paths['/api/v1/oauth2/google']['post']['responses'][200]['content']['*/*'];

export const loginAsReviewer = async (key: string) => {
  const { data } = await authApi.post<LoginResponse>(
    '/api/v1/reviewer/login',
    null,
    {
      headers: { 'X-Reviewer-Key': key }
    }
  );

  return data;
};
