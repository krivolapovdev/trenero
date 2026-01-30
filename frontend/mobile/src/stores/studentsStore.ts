import { create } from 'zustand';
import type { components } from '@/src/api/generated/openapi';

type StudentOverview = components['schemas']['StudentOverviewResponse'];
type StudentDetails = components['schemas']['StudentDetailsResponse'];

type StudentsStore = {
  allStudents: StudentOverview[];
  recentStudents: StudentDetails[];
  setAllStudents: (students: StudentOverview[]) => void;
  addStudent: (student: StudentDetails) => void;
  getStudentsByGroup: (groupId: string) => StudentOverview[];
  removeStudent: (id: string) => void;
};

export const useStudentsStore = create<StudentsStore>((set, get) => ({
  allStudents: [],

  recentStudents: [],

  setAllStudents: students => set({ allStudents: students }),

  addStudent: student =>
    set(state => {
      const otherAll = state.allStudents.filter(s => s.id !== student.id);
      const otherRecent = state.recentStudents.filter(s => s.id !== student.id);

      return {
        allStudents: [student, ...otherAll],
        recentStudents: [student, ...otherRecent].slice(0, 10)
      };
    }),

  getStudentsByGroup: groupId =>
    get().allStudents.filter(s => s.groupId === groupId),

  removeStudent: id =>
    set(state => ({
      allStudents: state.allStudents.filter(s => s.id !== id),
      recentStudents: state.recentStudents.filter(s => s.id !== id)
    }))
}));
