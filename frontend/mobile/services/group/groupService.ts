import { api } from '@/services';
import type { GroupResponse } from '@/types';

const baseURL = '/api/v1/groups';

export const groupService = {
  async getAllGroups() {
    const { data } = await api.get<GroupResponse[]>(`${baseURL}`);
    return data;
  },

  async getGroupById(id: string) {
    const { data } = await api.get<GroupResponse>(`${baseURL}/${id}`);
    return data;
  },

  async createGroup(name: string, defaultPrice?: number | null) {
    const { data: id } = await api.post<string>(`${baseURL}`, {
      name,
      defaultPrice
    });
    return id;
  }
};
