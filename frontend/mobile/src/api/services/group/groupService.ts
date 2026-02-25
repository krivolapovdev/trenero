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

export const getGroupsOverview = async () => {
  const { data } = await api.get<GroupsOverviewResponse>(
    '/api/v1/groups/overview'
  );
  return data;
};

export const getGroupDetails = async (groupId: string) => {
  const { data } = await api.get<GroupDetailsResponse>(
    `/api/v1/groups/${groupId}/details`
  );
  return data;
};

export const createGroup = async (body: CreateGroupRequest) => {
  const { data } = await api.post<GroupResponse>('/api/v1/groups', body);
  return data;
};

export const updateGroup = async (
  groupId: string,
  body: UpdateGroupRequest
) => {
  const { data } = await api.patch<GroupResponse>(
    `/api/v1/groups/${groupId}`,
    body
  );
  return data;
};

export const deleteGroup = async (groupId: string) => {
  await api.delete(`/api/v1/groups/${groupId}`);
};
