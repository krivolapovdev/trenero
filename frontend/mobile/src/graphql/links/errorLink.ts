import { CombinedGraphQLErrors, Observable } from '@apollo/client';
import { ErrorLink } from '@apollo/client/link/error';
import { graphql } from '@/src/graphql/__generated__';
import { useAuthStore } from '@/src/stores/authStore';

const REFRESH_TOKENS = graphql(`
    mutation RefreshTokens($input: RefreshTokenInput!) {
        refreshTokens(input: $input) {
            accessToken
            refreshToken
        }
    }
`);

export const errorLink = new ErrorLink(({ error, operation, forward }) => {
  const isUnauthenticatedGraphql =
    CombinedGraphQLErrors.is(error) &&
    error.errors.some(err => err.extensions?.code === 'UNAUTHENTICATED');

  const isUnauthorizedHttp =
    error instanceof Error &&
    'statusCode' in error &&
    (error.statusCode === 401 || error.statusCode === 403);

  if (!isUnauthenticatedGraphql && !isUnauthorizedHttp) {
    return;
  }

  return new Observable(observer => {
    let subscription: { unsubscribe: () => void } | null = null;

    (async () => {
      try {
        const state = useAuthStore.getState();
        const refreshToken = await state.getRefreshToken();
        const user = state.user;

        if (!refreshToken || !user) {
          await state.logout();
          observer.error(new Error('No session available'));
          return;
        }

        const { client } = await import('@/src/graphql');

        const { data } = await client.mutate({
          mutation: REFRESH_TOKENS,
          variables: {
            input: { refreshToken }
          },
          context: { skipAuthLink: true }
        });

        const jwtTokens = data?.refreshTokens;
        if (!jwtTokens) {
          await state.logout();
          observer.error(new Error('Refresh failed: empty response'));
          return;
        }

        await state.setAuth({ user, jwtTokens });

        operation.setContext(({ headers = {} }) => ({
          headers: {
            ...headers,
            Authorization: `Bearer ${jwtTokens.accessToken}`
          }
        }));

        subscription = forward(operation).subscribe(observer);
      } catch (err) {
        await useAuthStore.getState().logout();
        observer.error(err);
      }
    })();

    return () => subscription?.unsubscribe();
  });
});
