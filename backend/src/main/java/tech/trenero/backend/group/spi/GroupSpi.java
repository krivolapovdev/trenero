package tech.trenero.backend.group.spi;

import java.util.List;
import java.util.UUID;
import tech.trenero.backend.common.response.GroupResponse;

public interface GroupSpi {
  List<GroupResponse> getGroupsByIds(List<UUID> groupIds);
}
