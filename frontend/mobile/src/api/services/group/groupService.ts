import { api } from '@/src/api';
import type { paths } from '@/src/api/generated/openapi';

type CreateGroupRequest =
  paths['/api/v1/groups']['post']['requestBody']['content']['application/json'];
type UpdateGroupRequest =
  paths['/api/v1/groups/{groupId}']['patch']['requestBody']['content']['application/json'];

type GroupsOverviewResponse =
  paths['/api/v1/groups/overview']['get']['responses'][200]['content']['*/*'];
type GroupResponse =
  paths['/api/v1/groups']['post']['responses'][201]['content']['*/*'];
type GroupDetailsResponse =
  paths['/api/v1/groups/{groupId}/details']['get']['responses'][200]['content']['*/*'];

export const groupService = {
  async getOverview() {
    const { data } = await api.get<GroupsOverviewResponse>(
      '/api/v1/groups/overview'
    );

    return data;
  },

  async getDetails(groupId: string) {
    const { data } = await api.get<GroupDetailsResponse>(
      `/api/v1/groups/${groupId}/details`
    );

    return data;
  },

  async create(body: CreateGroupRequest) {
    const { data } = await api.post<GroupResponse>('/api/v1/groups', body);
    return data;
  },

  async update(groupId: string, body: UpdateGroupRequest) {
    const { data } = await api.patch<GroupResponse>(
      `/api/v1/groups/${groupId}`,
      body
    );
    return data;
  },

  async delete(groupId: string) {
    await api.delete(`/api/v1/groups/${groupId}`);
  }
};
