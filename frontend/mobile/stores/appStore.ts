import { create } from 'zustand';
import type { GroupResponse } from '@/types/group';
import type { StudentResponse } from '@/types/student';

type AppStore = {
  students: StudentResponse[];
  groups: GroupResponse[];
  setStudents: (students: StudentResponse[]) => void;
  setGroups: (groups: GroupResponse[]) => void;
};

export const useAppStore = create<AppStore>(set => ({
  students: [],
  groups: [],
  setStudents: students => set({ students }),
  setGroups: groups => set({ groups })
}));
