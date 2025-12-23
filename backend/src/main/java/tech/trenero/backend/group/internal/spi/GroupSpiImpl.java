package tech.trenero.backend.group.internal.spi;

import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import tech.trenero.backend.common.dto.GroupDto;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;
import tech.trenero.backend.group.internal.entity.Group;
import tech.trenero.backend.group.internal.mapper.GroupMapper;
import tech.trenero.backend.group.internal.service.GroupService;

@Service
@RequiredArgsConstructor
public class GroupSpiImpl implements GroupSpi {
  private final GroupService groupService;
  private final GroupMapper groupMapper;

  @Override
  public Optional<GroupDto> getGroupById(UUID groupId, JwtUser jwtUser) {
    Optional<Group> group = groupService.getGroupById(groupId, jwtUser);
    return group.map(groupMapper::toGroupDto);
  }
}
