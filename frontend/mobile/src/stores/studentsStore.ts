import { create } from 'zustand';
import type { components } from '@/src/api/generated/openapi';
import { studentService } from '@/src/api/services/student/studentService';

type StudentOverview = components['schemas']['StudentOverviewResponse'];
type StudentDetails = components['schemas']['StudentDetailsResponse'];

type StudentsStore = {
  allStudents: StudentOverview[];
  recentStudents: StudentDetails[];

  isRefreshing: boolean;
  refreshStudents: () => Promise<void>;

  setAllStudents: (students: StudentOverview[]) => void;
  addStudent: (student: StudentDetails) => void;
  getStudentsByGroup: (groupId: string) => StudentOverview[];
  removeStudent: (id: string) => void;

  removePayment: (studentId: string, paymentId: string) => void;
};

export const useStudentsStore = create<StudentsStore>((set, get) => ({
  allStudents: [],

  recentStudents: [],

  isRefreshing: false,

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
    get().allStudents.filter(s => s.studentGroup?.id === groupId),

  removeStudent: id =>
    set(state => ({
      allStudents: state.allStudents.filter(s => s.id !== id),
      recentStudents: state.recentStudents.filter(s => s.id !== id)
    })),

  refreshStudents: async () => {
    set({ isRefreshing: true });
    try {
      const data = await studentService.getOverview();
      set({ allStudents: data, recentStudents: [] });
    } catch (error) {
      console.error('Failed to refresh students:', error);
    } finally {
      set({ isRefreshing: false });
    }
  },

  removePayment: (studentId, paymentId) =>
    set(state => ({
      recentStudents: state.recentStudents.map(s => {
        if (s.id === studentId) {
          return {
            ...s,
            studentPayments: s.studentPayments.filter(p => p.id !== paymentId)
          };
        }

        return s;
      })
    }))
}));
