import { api } from '@/src/api';

export const deleteAccount = async () => {
  await api.delete('/api/v1/users/me');
};
