import { useQuery } from '@apollo/client/react';
import { graphql } from '@/src/graphql/__generated__';
import { useAuthStore } from '@/src/stores/authStore';

const GET_INIT_DATA = graphql(`
    query GetInitialData {
        groups {
            ...GroupFields
        }
        students {
            ...StudentFields
        }
        payments {
            ...PaymentFields
        }
    }
`);

export function useInitApp() {
  const user = useAuthStore(state => state.user);

  const { loading, error } = useQuery(GET_INIT_DATA, {
    fetchPolicy: 'network-only',
    skip: !user
  });

  return { loading, error };
}
