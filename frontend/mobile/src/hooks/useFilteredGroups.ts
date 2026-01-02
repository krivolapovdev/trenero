import { useDeferredValue, useMemo } from 'react';
import type { GetGroupsQuery } from '@/src/graphql/__generated__/graphql';

export function useFilteredGroups(
  groups: GetGroupsQuery['groups'],
  searchQuery: string
) {
  const deferredQuery = useDeferredValue(searchQuery).trim().toLowerCase();
  const allGroups = groups;

  return useMemo(
    () =>
      allGroups.filter(
        group =>
          !deferredQuery || group.name.toLowerCase().includes(deferredQuery)
      ),
    [allGroups, deferredQuery]
  );
}
