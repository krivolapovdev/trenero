package tech.trenero.backend.group.external;

import jakarta.persistence.EntityNotFoundException;
import java.util.UUID;
import tech.trenero.backend.common.security.JwtUser;

public interface GroupValidator {
  void validateGroup(UUID groupId, JwtUser jwtUser) throws EntityNotFoundException;
}
