import { ApolloClient, ApolloLink, InMemoryCache } from '@apollo/client';
import { authLink } from '@/src/graphql/links/authLink';
import { errorLink } from '@/src/graphql/links/errorLink';
import { httpLink } from '@/src/graphql/links/httpLink';
import { timeoutLink } from '@/src/graphql/links/timeoutLink';

export const client = new ApolloClient({
  link: ApolloLink.from([timeoutLink, errorLink, authLink, httpLink]),
  cache: new InMemoryCache()
});
