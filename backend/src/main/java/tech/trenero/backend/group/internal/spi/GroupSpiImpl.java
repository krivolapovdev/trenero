package tech.trenero.backend.group.internal.spi;

import jakarta.persistence.EntityNotFoundException;
import java.util.Objects;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import tech.trenero.backend.codegen.types.Group;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;
import tech.trenero.backend.group.internal.service.GroupService;

@Component
@RequiredArgsConstructor
public class GroupSpiImpl implements GroupSpi {
  private final GroupService groupService;

  @Override
  public Optional<Group> findGroupById(UUID groupId, JwtUser jwtUser) {
    Objects.requireNonNull(groupId, "groupId must not be null");
    Objects.requireNonNull(jwtUser, "jwtUser must not be null");
    return groupService.findGroupById(groupId, jwtUser);
  }

  @Override
  public Group getGroupById(UUID groupId, JwtUser jwtUser) throws EntityNotFoundException {
    return findGroupById(groupId, jwtUser)
        .orElseThrow(
            () -> new EntityNotFoundException("Group not found: groupId=%s".formatted(groupId)));
  }
}
