import { create } from 'zustand';
import type { GroupDetails, GroupOverview } from '@/src/types/group';

type GroupsStore = {
  allGroups: Record<string, GroupOverview | GroupDetails>;

  setAllGroups: (groups: GroupOverview[]) => void;
  addGroup: (group: GroupDetails) => void;
  updateGroup: (id: string, updates: Partial<GroupDetails>) => void;
  removeGroup: (id: string) => void;
};

export const useGroupsStore = create<GroupsStore>((set, _get) => ({
  allGroups: {},

  setAllGroups: groups => {
    const groupsMap = groups.reduce(
      (acc, g) => {
        acc[g.id] = g;
        return acc;
      },
      {} as Record<string, GroupOverview>
    );

    set({ allGroups: groupsMap });
  },

  addGroup: group =>
    set(state => ({
      allGroups: {
        ...state.allGroups,
        [group.id]: group
      }
    })),

  updateGroup: (id, updates) =>
    set(state => {
      const group = state.allGroups[id];
      if (!group) {
        return state;
      }

      return {
        allGroups: {
          ...state.allGroups,
          [id]: { ...group, ...updates }
        }
      };
    }),

  removeGroup: id =>
    set(state => {
      const { [id]: _, ...newAll } = state.allGroups;
      return { allGroups: newAll };
    })
}));
