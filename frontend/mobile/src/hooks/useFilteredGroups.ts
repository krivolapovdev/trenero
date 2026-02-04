import { useDeferredValue, useMemo } from 'react';
import type { components } from '@/src/api/generated/openapi';

type GroupOverview = components['schemas']['GroupOverviewResponse'];

export function useFilteredGroups(
  groupsRecord: Record<string, GroupOverview>,
  searchQuery: string
) {
  const deferredQuery = useDeferredValue(searchQuery).trim().toLowerCase();

  return useMemo(() => {
    const allGroups = Object.values(groupsRecord);

    if (!deferredQuery) {
      return allGroups;
    }

    return allGroups.filter(group =>
      group.name.toLowerCase().includes(deferredQuery)
    );
  }, [deferredQuery, groupsRecord]);
}
