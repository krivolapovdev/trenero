package tech.trenero.backend.group.external;

import java.util.Optional;
import java.util.UUID;
import tech.trenero.backend.common.dto.GroupDto;
import tech.trenero.backend.common.security.JwtUser;

public interface GroupSpi {
  Optional<GroupDto> getGroupById(UUID groupId, JwtUser jwtUser);
}
