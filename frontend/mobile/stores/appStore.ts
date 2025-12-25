import { create } from 'zustand';
import type { Group, Student } from '@/graphql/types';

type AppStore = {
  students: Student[];
  groups: Group[];
  setStudents: (students: Student[]) => void;
  setGroups: (groups: Group[]) => void;
};

export const useAppStore = create<AppStore>(set => ({
  students: [],
  groups: [],
  setStudents: students => set({ students }),
  setGroups: groups => set({ groups })
}));
