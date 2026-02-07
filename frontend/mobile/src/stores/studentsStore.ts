import { create } from 'zustand';
import { studentService } from '@/src/api/services/student/studentService';
import { extractErrorMessage } from '@/src/helpers/apiError';
import type { StudentDetails, StudentOverview } from '@/src/types/student';

type StudentsStore = {
  allStudents: Record<string, StudentOverview | StudentDetails>;
  isRefreshing: boolean;
  error: string | null;

  setAllStudents: (students: StudentOverview[]) => void;
  refreshStudents: () => Promise<void>;
  addStudent: (student: StudentDetails) => void;
  removeStudent: (id: string) => void;
  removePayment: (studentId: string, paymentId: string) => void;
};

export const useStudentsStore = create<StudentsStore>((set, get) => ({
  allStudents: {},
  isRefreshing: false,
  error: null,

  setAllStudents: students => {
    const studentsMap = students.reduce(
      (acc, s) => {
        acc[s.id] = s;
        return acc;
      },
      {} as Record<string, StudentOverview>
    );

    set({ allStudents: studentsMap });
  },

  refreshStudents: async () => {
    set({ isRefreshing: true, error: null });
    try {
      const data = await studentService.getOverview();
      get().setAllStudents(data);
    } catch (e: unknown) {
      set({ error: extractErrorMessage(e) });
    } finally {
      set({ isRefreshing: false });
    }
  },

  addStudent: student =>
    set(state => ({
      allStudents: {
        ...state.allStudents,
        [student.id]: student
      }
    })),

  removeStudent: id =>
    set(state => {
      const { [id]: _, ...nextEntities } = state.allStudents;
      return { allStudents: nextEntities };
    }),

  removePayment: (studentId, paymentId) => {
    set(state => {
      const student = state.allStudents[studentId];

      if (!student || !('studentPayments' in student)) {
        return state;
      }

      return {
        allStudents: {
          ...state.allStudents,
          [studentId]: {
            ...student,
            studentPayments: student.studentPayments.filter(
              p => p.id !== paymentId
            )
          }
        }
      };
    });
  }
}));
