import { api } from '@/services';
import type { StudentResponse } from '@/types';

const baseURL = '/api/v1/students';

export const studentService = {
  async getAllStudents() {
    const { data } = await api.get<StudentResponse[]>(`${baseURL}`);
    return data;
  },

  async getStudentById(id: string) {
    const { data } = await api.get<StudentResponse>(`${baseURL}/${id}`);
    return data;
  },

  async createStudent(
    fullName: string,
    phone?: string | null,
    birthDate?: Date | null,
    note?: string | null
  ) {
    const { data: id } = await api.post<string>(`${baseURL}`, {
      fullName,
      phone,
      birthDate,
      note
    });
    return id;
  }
};
