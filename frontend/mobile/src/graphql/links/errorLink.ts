import { CombinedGraphQLErrors, Observable } from '@apollo/client';
import { ErrorLink } from '@apollo/client/link/error';
import { graphql } from '@/src/graphql/__generated__';
import { useAuthStore } from '@/src/stores/authStore';

const REFRESH_TOKEN = graphql(`
    mutation RefreshTokens($input: RefreshTokenInput!) {
        refreshTokens(input: $input) {
            accessToken
            refreshToken
        }
    }
`);

export const errorLink = new ErrorLink(({ error, operation, forward }) => {
  const isAuthError =
    (CombinedGraphQLErrors.is(error) &&
      error.errors.some(err => err.extensions?.code === 'UNAUTHENTICATED')) ||
    (error as any)?.statusCode === 401 ||
    (error as any)?.statusCode === 403;

  if (!isAuthError) {
    return;
  }

  return new Observable(observer => {
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
          mutation: REFRESH_TOKEN,
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

        const subscription = forward(operation).subscribe({
          next: observer.next.bind(observer),
          error: observer.error.bind(observer),
          complete: observer.complete.bind(observer)
        });

        return () => subscription.unsubscribe();
      } catch (err) {
        await useAuthStore.getState().logout();
        observer.error(err);
      }
    })();
  });
});
