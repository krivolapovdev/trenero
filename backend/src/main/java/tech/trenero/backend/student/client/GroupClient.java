package tech.trenero.backend.student.client;

import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.group.spi.GroupSpi;

@Component
@RequiredArgsConstructor
public class GroupClient {
  @Lazy private final GroupSpi groupSpi;

  public List<GroupResponse> getGroupsByIds(List<UUID> groupIds) {
    if (groupIds == null || groupIds.isEmpty()) {
      return List.of();
    }

    return groupSpi.getGroupsByIds(groupIds);
  }
}
