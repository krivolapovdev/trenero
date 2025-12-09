package tech.trenero.backend.student.internal.client;

import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;

@Component
@RequiredArgsConstructor
public class GroupClient {
  @Lazy private final GroupSpi groupSpi;

  public List<GroupResponse> getGroupsByIdsAndOwner(List<UUID> groupIds, JwtUser jwtUser) {
    if (groupIds == null || groupIds.isEmpty() || jwtUser == null) {
      return List.of();
    }

    return groupSpi.getGroupsByIdsAndOwner(groupIds, jwtUser);
  }
}
