package tech.trenero.backend.group.internal.spi;

import static java.util.Objects.requireNonNull;

import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;
import tech.trenero.backend.group.internal.service.GroupService;

@Service
@RequiredArgsConstructor
@Slf4j
public class GroupSpiImpl implements GroupSpi {
  public static final String VALIDATION_JWT_USER_REQUIRED = "jwtUser must not be null";

  private final GroupService groupService;

  @Override
  public GroupResponse getGroupById(UUID groupId, JwtUser jwtUser) {
    requireNonNull(groupId, "groupId must not be null");
    requireNonNull(jwtUser, VALIDATION_JWT_USER_REQUIRED);
    log.debug("Fetching group by id={} for user={}", groupId, jwtUser.userId());
    return groupService.getGroupById(groupId, jwtUser);
  }

  @Override
  public List<GroupResponse> getGroupsByStudentId(UUID studentId, JwtUser jwtUser) {
    requireNonNull(studentId, "studentId must not be null");
    requireNonNull(jwtUser, VALIDATION_JWT_USER_REQUIRED);
    log.debug("Fetching groups for studentId={} and user={}", studentId, jwtUser.userId());
    return groupService.getGroupsByStudentId(studentId, jwtUser);
  }

  @Override
  public void assignGroupsToStudent(UUID studentId, List<UUID> studentGroups, JwtUser jwtUser) {
    requireNonNull(studentId, "studentId must not be null");
    requireNonNull(studentGroups, "studentGroups must not be null");
    requireNonNull(jwtUser, VALIDATION_JWT_USER_REQUIRED);
    log.debug(
        "Assigning groups={} to studentId={} by user={}",
        studentGroups,
        studentId,
        jwtUser.userId());
    groupService.assignGroupsToStudent(studentId, studentGroups, jwtUser);
  }
}
