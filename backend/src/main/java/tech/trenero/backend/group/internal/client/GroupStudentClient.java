package tech.trenero.backend.group.internal.client;

import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.student.external.StudentSpi;

@Component
@RequiredArgsConstructor
@Slf4j
public class GroupStudentClient {
  @Lazy private final StudentSpi studentSpi;

  public StudentResponse getStudentById(UUID studentId, JwtUser jwtUser) {
    log.debug("Fetching student by id={} for user={}", studentId, jwtUser.userId());
    return studentSpi.getStudentById(studentId, jwtUser);
  }

  public List<StudentResponse> getStudentsByIds(List<UUID> studentIds, JwtUser jwtUser) {
    log.debug("Fetching students by ids={} for user={}", studentIds.toString(), jwtUser.userId());
    return studentSpi.getStudentsByIds(studentIds, jwtUser);
  }

  public void checkStudentExists(UUID studentId, JwtUser jwtUser) {
    log.debug("Checking if student exists by id={} for user={}", studentId, jwtUser.userId());
    getStudentById(studentId, jwtUser);
  }
}
