import { gql } from '@apollo/client';
import { useQuery } from '@apollo/client/react';
import { GROUP_FIELDS, STUDENT_FIELDS } from '@/graphql/fragments';
import type { Group, Student } from '@/graphql/types';
import { useAuthStore } from '@/stores/authStore';

const QUERY = gql`
    query GetInitialData {
        groups {
            ...GroupFields
        }
        students {
            ...StudentFields
        }
    }
    ${GROUP_FIELDS}
    ${STUDENT_FIELDS}
`;

export function useInitApp() {
  const user = useAuthStore(state => state.user);

  const { loading, error } = useQuery<{ groups: Group[]; students: Student[] }>(
    QUERY,
    {
      fetchPolicy: 'network-only',
      skip: !user
    }
  );

  return { loading, error };
}
