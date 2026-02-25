import { api } from '@/src/api';
import type { paths } from '@/src/api/generated/openapi';

type CreateStudentPaymentRequest =
  paths['/api/v1/payments']['post']['requestBody']['content']['application/json'];
type UpdatePaymentRequest =
  paths['/api/v1/payments/{paymentId}']['patch']['requestBody']['content']['application/json'];

type UpdatePaymentResponse =
  paths['/api/v1/payments/{paymentId}']['patch']['responses'][200]['content']['*/*'];
type StudentPaymentResponse =
  paths['/api/v1/payments']['post']['responses'][201]['content']['*/*'];

export const createPayment = async (body: CreateStudentPaymentRequest) => {
  const { data } = await api.post<StudentPaymentResponse>(
    '/api/v1/payments',
    body
  );
  return data;
};

export const updatePayment = async (
  paymentId: string,
  body: UpdatePaymentRequest
) => {
  const { data } = await api.patch<UpdatePaymentResponse>(
    `/api/v1/payments/${paymentId}`,
    body
  );

  return data;
};

export const deletePayment = async (paymentId: string) => {
  await api.delete(`/api/v1/payments/${paymentId}`);
};
