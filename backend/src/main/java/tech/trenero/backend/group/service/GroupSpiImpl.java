package tech.trenero.backend.group.service;

import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.group.spi.GroupSpi;

@Service
@RequiredArgsConstructor
@Slf4j
public class GroupSpiImpl implements GroupSpi {
  private final GroupService groupService;

  @Override
  public List<GroupResponse> getGroupsByIds(List<UUID> groupIds) {
    return groupService.getGroupsByIds(groupIds);
  }
}
