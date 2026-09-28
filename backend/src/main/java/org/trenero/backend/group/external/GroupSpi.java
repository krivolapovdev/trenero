package org.trenero.backend.group.external;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.trenero.backend.common.response.GroupResponse;
import org.trenero.backend.common.security.JwtUser;

public interface GroupSpi {
  GroupResponse getGroupById(UUID groupId, JwtUser jwtUser);

  Map<UUID, GroupResponse> getGroupsByIds(List<UUID> groupIds, JwtUser jwtUser);
}
