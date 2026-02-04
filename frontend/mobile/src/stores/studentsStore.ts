import { create } from 'zustand';
import { studentService } from '@/src/api/services/student/studentService';
import type { StudentDetails, StudentOverview } from '@/src/types/student';

type StudentsStore = {
  allStudents: Record<string, StudentOverview | StudentDetails>;

  isRefreshing: boolean;
  refreshStudents: () => Promise<void>;

  setAllStudents: (students: StudentOverview[]) => void;
  addStudent: (student: StudentDetails) => void;
  removeStudent: (id: string) => void;

  removePayment: (studentId: string, paymentId: string) => void;
};

export const useStudentsStore = create<StudentsStore>((set, _get) => ({
  allStudents: {},
  recentStudents: {},
  isRefreshing: false,

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

  addStudent: student =>
    set(state => ({
      allStudents: {
        ...state.allStudents,
        [student.id]: student
      }
    })),

  refreshStudents: async () => {
    set({ isRefreshing: true });
    try {
      const data = await studentService.getOverview();
      const studentsMap = data.reduce(
        (acc, s) => {
          acc[s.id] = s;
          return acc;
        },
        {} as Record<string, StudentOverview>
      );

      set({ allStudents: studentsMap });
    } catch (error) {
      console.error('Failed to refresh students:', error);
    } finally {
      set({ isRefreshing: false });
    }
  },

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
