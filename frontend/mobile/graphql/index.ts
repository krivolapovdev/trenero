import { ApolloClient, HttpLink, InMemoryCache } from '@apollo/client';
import { authLink } from '@/graphql/authLink';
import { errorLink } from '@/graphql/errorLink';

const httpLink = new HttpLink({
  uri: 'http://192.168.1.4:8080/graphql'
});

export const client = new ApolloClient({
  link: errorLink.concat(authLink).concat(httpLink),
  cache: new InMemoryCache()
});
