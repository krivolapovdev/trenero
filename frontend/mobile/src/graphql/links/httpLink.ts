import { HttpLink } from '@apollo/client';

export const httpLink = new HttpLink({
  uri: process.env.EXPO_PUBLIC_GRAPHQL_URL
});
