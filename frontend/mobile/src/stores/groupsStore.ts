import { create } from 'zustand';
import type { components } from '@/src/api/generated/openapi';

type GroupOverview = components['schemas']['GroupOverviewResponse'];
type GroupDetails = components['schemas']['GroupDetailsResponse'];

type GroupsStore = {
  allGroups: GroupOverview[];
  recentGroups: GroupDetails[];

  setAllGroups: (groups: GroupOverview[]) => void;
  addGroup: (group: GroupDetails) => void;
  updateGroup: (id: string, updates: Partial<GroupDetails>) => void;
  removeGroup: (id: string) => void;
};

export const useGroupsStore = create<GroupsStore>((set, _get) => ({
  allGroups: [],

  recentGroups: [],

  setAllGroups: groups => set({ allGroups: groups }),

  addGroup: group =>
    set(state => {
      const otherAll = state.allGroups.filter(g => g.id !== group.id);
      const otherRecent = state.recentGroups.filter(g => g.id !== group.id);

      return {
        allGroups: [group, ...otherAll],
        recentGroups: [group, ...otherRecent].slice(0, 10)
      };
    }),

  updateGroup: (id, updates) =>
    set(state => ({
      allGroups: state.allGroups.map(group =>
        group.id === id ? { ...group, ...updates } : group
      ),
      recentGroups: state.recentGroups.map(group =>
        group.id === id ? { ...group, ...updates } : group
      )
    })),

  removeGroup: id =>
    set(state => ({
      allGroups: state.allGroups.filter(g => g.id !== id),
      recentGroups: state.recentGroups.filter(g => g.id !== id)
    }))
}));
