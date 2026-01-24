import { useDeferredValue, useMemo } from 'react';
import type { components } from '@/src/api/generated/openapi';

export function useFilteredGroups(
  groups: components['schemas']['GroupResponse'][],
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
