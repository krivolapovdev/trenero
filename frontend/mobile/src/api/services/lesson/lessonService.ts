import { api } from '@/src/api';
import type { paths } from '@/src/api/generated/openapi';

type CreateLessonRequest =
  paths['/api/v1/lessons']['post']['requestBody']['content']['application/json'];
type UpdateLessonRequest =
  paths['/api/v1/lessons/{lessonId}']['patch']['requestBody']['content']['application/json'];

type LessonResponse =
  paths['/api/v1/lessons']['post']['responses'][201]['content']['*/*'];
type LessonDetailsResponse =
  paths['/api/v1/lessons/{lessonId}/details']['get']['responses'][200]['content']['*/*'];

export const getLessonDetails = async (lessonId: string) => {
  const { data } = await api.get<LessonDetailsResponse>(
    `/api/v1/lessons/${lessonId}/details`
  );

  return data;
};

export const createLesson = async (body: CreateLessonRequest) => {
  const { data } = await api.post<LessonResponse>('/api/v1/lessons', body);
  return data;
};

export const updateLesson = async (
  lessonId: string,
  body: UpdateLessonRequest
) => {
  const { data } = await api.patch<
    paths['/api/v1/lessons/{lessonId}']['patch']['responses'][200]['content']['*/*']
  >(`/api/v1/lessons/${lessonId}`, body);

  return data;
};
