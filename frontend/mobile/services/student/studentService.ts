import { api } from '@/services';
import type { StudentResponse } from '@/services/student/student.types';

const baseURL = '/api/v1/students';

export const studentService = {
  async getAllStudents() {
    const { data } = await api.get<StudentResponse[]>(`${baseURL}`);
    return data;
  },

  async getStudentById(id: string) {
    const { data } = await api.get<StudentResponse>(`${baseURL}/${id}`);
    return data;
  }
};
