package tech.trenero.backend.group.external;

import jakarta.persistence.EntityNotFoundException;
import java.util.Optional;
import java.util.UUID;
import tech.trenero.backend.codegen.types.Group;
import tech.trenero.backend.common.security.JwtUser;

public interface GroupSpi {
  Optional<Group> findGroupById(UUID groupId, JwtUser jwtUser);

  @SuppressWarnings("UnusedReturnValue")
  Group getGroupById(UUID groupId, JwtUser jwtUser) throws EntityNotFoundException;
}
