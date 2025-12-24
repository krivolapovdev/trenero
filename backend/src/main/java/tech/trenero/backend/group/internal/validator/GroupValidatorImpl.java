package tech.trenero.backend.group.internal.validator;

import jakarta.persistence.EntityNotFoundException;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupValidator;
import tech.trenero.backend.group.internal.service.GroupService;

@Component
@RequiredArgsConstructor
public class GroupValidatorImpl implements GroupValidator {
  private final GroupService groupService;

  @Override
  public void validateGroup(UUID groupId, JwtUser jwtUser) throws EntityNotFoundException {
    groupService
        .getGroupById(groupId, jwtUser)
        .orElseThrow(() -> new EntityNotFoundException("Group not found by id: " + groupId));
  }
}
