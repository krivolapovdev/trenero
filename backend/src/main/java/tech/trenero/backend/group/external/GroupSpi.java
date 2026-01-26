package tech.trenero.backend.group.external;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.security.JwtUser;

public interface GroupSpi {
  List<GroupResponse> getAllGroups(JwtUser jwtUser);

  GroupResponse getGroupById(UUID groupId, JwtUser jwtUser);

  Map<UUID, GroupResponse> getGroupsByIds(List<UUID> groupIds, JwtUser jwtUser);
}
