import { ApolloClient, HttpLink, InMemoryCache } from '@apollo/client';
import { SetContextLink } from '@apollo/client/link/context';
import { useAuthStore } from '@/stores/authStore';

const httpLink = new HttpLink({
  uri: 'http://192.168.1.4:8080/graphql'
});

const authLink = new SetContextLink(prevContext => {
  const accessToken = useAuthStore.getState().accessToken;

  return {
    ...prevContext,
    headers: {
      ...prevContext.headers,
      ...(accessToken && { Authorization: `Bearer ${accessToken}` })
    }
  };
});

export const client = new ApolloClient({
  link: authLink.concat(httpLink),
  cache: new InMemoryCache()
});
