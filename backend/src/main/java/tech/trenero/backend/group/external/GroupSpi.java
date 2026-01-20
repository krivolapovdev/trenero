package tech.trenero.backend.group.external;

import jakarta.persistence.EntityNotFoundException;
import java.util.UUID;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.security.JwtUser;

public interface GroupSpi {
  GroupResponse getGroupById(UUID groupId, JwtUser jwtUser) throws EntityNotFoundException;
}
