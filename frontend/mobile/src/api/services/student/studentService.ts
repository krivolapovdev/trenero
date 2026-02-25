import { api } from '@/src/api';
import type { paths } from '@/src/api/generated/openapi';

type CreateStudentRequest =
  paths['/api/v1/students']['post']['requestBody']['content']['application/json'];
type UpdateStudentRequest =
  paths['/api/v1/students/{studentId}']['patch']['requestBody']['content']['application/json'];

type StudentsOverviewResponse =
  paths['/api/v1/students/overview']['get']['responses'][200]['content']['*/*'];
type StudentResponse =
  paths['/api/v1/students']['post']['responses'][201]['content']['*/*'];
type StudentDetailsResponse =
  paths['/api/v1/students/{studentId}/details']['get']['responses'][200]['content']['*/*'];

export const getStudentsOverview = async () => {
  const { data } = await api.get<StudentsOverviewResponse>(
    '/api/v1/students/overview'
  );

  return data;
};

export const getStudentDetails = async (studentId: string) => {
  const { data } = await api.get<StudentDetailsResponse>(
    `/api/v1/students/${studentId}/details`
  );

  return data;
};

export const createStudent = async (body: CreateStudentRequest) => {
  const { data } = await api.post<StudentResponse>('/api/v1/students', body);
  return data;
};

export const updateStudent = async (
  studentId: string,
  body: UpdateStudentRequest
) => {
  const { data } = await api.patch<StudentResponse>(
    `/api/v1/students/${studentId}`,
    body
  );

  return data;
};

export const deleteStudent = async (studentId: string) => {
  await api.delete(`/api/v1/students/${studentId}`);
};
