package tech.trenero.backend.group.internal.spi;

import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;
import tech.trenero.backend.group.internal.service.GroupService;

@Service
@RequiredArgsConstructor
@Slf4j
public class GroupSpiImpl implements GroupSpi {
  private final GroupService groupService;

  @Override
  public List<GroupResponse> getGroupsByIdsAndOwner(List<UUID> groupIds, JwtUser jwtUser) {
    if (groupIds == null) {
      throw new IllegalArgumentException("groupIds must not be null");
    }

    if (jwtUser == null) {
      throw new IllegalArgumentException("jwtUser must not be null");
    }

    if (groupIds.isEmpty()) {
      return List.of();
    }

    return groupService.getGroupsByIdsAndOwner(groupIds, jwtUser);
  }

  @Override
  public GroupResponse getGroupForUserById(UUID groupId, JwtUser jwtUser) {
    if (groupId == null) {
      throw new IllegalArgumentException("groupId must not be null");
    }

    if (jwtUser == null) {
      throw new IllegalArgumentException("jwtUser must not be null");
    }

    return groupService.getGroupForUserById(groupId, jwtUser);
  }
}
