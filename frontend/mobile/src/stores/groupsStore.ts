import { create } from 'zustand';
import { getGroupsOverview } from '@/src/api/services/group/groupService';
import { extractErrorMessage } from '@/src/helpers/apiError';
import type { GroupDetails, GroupOverview } from '@/src/types/group';

type GroupsStore = {
  allGroups: Record<string, GroupOverview | GroupDetails>;
  isRefreshing: boolean;
  error: string | null;

  setAllGroups: (groups: GroupOverview[]) => void;
  refreshGroups: () => Promise<void>;
  addGroup: (group: GroupDetails) => void;
  updateGroup: (id: string, updates: Partial<GroupDetails>) => void;
  removeGroup: (id: string) => void;
};

export const useGroupsStore = create<GroupsStore>((set, get) => ({
  allGroups: {},
  isRefreshing: false,
  error: null,

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

  refreshGroups: async () => {
    set({ isRefreshing: true, error: null });
    try {
      const data = await getGroupsOverview();
      get().setAllGroups(data);
    } catch (e: unknown) {
      set({ error: extractErrorMessage(e) });
    } finally {
      set({ isRefreshing: false });
    }
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
