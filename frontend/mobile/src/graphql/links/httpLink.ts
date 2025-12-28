import { HttpLink } from '@apollo/client';

export const httpLink = new HttpLink({
  uri: 'http://192.168.1.6:8080/graphql'
});
