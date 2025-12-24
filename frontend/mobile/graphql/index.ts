import { ApolloClient, HttpLink, InMemoryCache } from '@apollo/client';

export const client = new ApolloClient({
  link: new HttpLink({
    uri: 'http://192.168.1.4:8080/graphql'
  }),
  cache: new InMemoryCache()
});
