import { ApolloClient, ApolloLink, InMemoryCache } from '@apollo/client';
import { authLink } from '@/graphql/links/authLink';
import { errorLink } from '@/graphql/links/errorLink';
import { httpLink } from '@/graphql/links/httpLink';
import { timeoutLink } from '@/graphql/links/timeoutLink';

export const client = new ApolloClient({
  link: ApolloLink.from([timeoutLink, errorLink, authLink, httpLink]),
  cache: new InMemoryCache()
});
