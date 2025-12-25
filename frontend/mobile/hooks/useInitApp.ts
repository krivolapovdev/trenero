import { gql } from '@apollo/client';
import { useQuery } from '@apollo/client/react';
import { useEffect } from 'react';
import type { Group, Student } from '@/graphql/types';
import { useAppStore } from '@/stores/appStore';
import { useAuthStore } from '@/stores/authStore';

const QUERY = gql`
    query {
        groups {
            id
            name
            defaultPrice
        }
        students {
            id
            fullName
            group {
                id
                name
            }
        }
    }
`;

export function useInitApp() {
  const user = useAuthStore(state => state.user);
  const setGroups = useAppStore(state => state.setGroups);
  const setStudents = useAppStore(state => state.setStudents);

  const { data, loading } = useQuery<{ groups: Group[]; students: Student[] }>(
    QUERY,
    {
      fetchPolicy: 'network-only',
      skip: !user
    }
  );

  useEffect(() => {
    if (data?.groups?.length) {
      setGroups(data.groups);
    }

    if (data?.students?.length) {
      setStudents(data.students);
    }
  }, [data, setGroups, setStudents]);

  return { loading };
}
