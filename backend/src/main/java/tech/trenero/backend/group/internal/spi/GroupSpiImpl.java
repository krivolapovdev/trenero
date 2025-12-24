package tech.trenero.backend.group.internal.spi;

import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.dto.GroupDto;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;
import tech.trenero.backend.group.internal.service.GroupService;

@Component
@RequiredArgsConstructor
public class GroupSpiImpl implements GroupSpi {
  private final GroupService groupService;

  @Override
  public Optional<GroupDto> getGroupById(UUID groupId, JwtUser jwtUser) {
    return groupService.getGroupById(groupId, jwtUser);
  }
}
