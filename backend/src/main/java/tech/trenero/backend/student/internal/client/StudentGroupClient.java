package tech.trenero.backend.student.internal.client;

import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;

@Component
@RequiredArgsConstructor
@Slf4j
public class StudentGroupClient {
  @Lazy private final GroupSpi groupSpi;

  public List<GroupResponse> getGroupsByStudentId(UUID studentId, JwtUser jwtUser) {
    log.debug("Fetching groups by studentId={} for user={}", studentId, jwtUser.userId());
    return groupSpi.getGroupsByStudentId(studentId, jwtUser);
  }

  public void assignGroupsToStudent(UUID studentId, List<UUID> studentGroups, JwtUser jwtUser) {
    log.debug("Assigning groups to student: studentId={}, groups={}", studentId, studentGroups);
    groupSpi.assignGroupsToStudent(studentId, studentGroups, jwtUser);
  }
}
