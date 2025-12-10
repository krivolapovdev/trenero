package tech.trenero.backend.student.internal.spi;

import static java.util.Objects.requireNonNull;

import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.student.external.StudentSpi;
import tech.trenero.backend.student.internal.service.StudentService;

@Service
@RequiredArgsConstructor
@Slf4j
public class StudentSpiImpl implements StudentSpi {
  private final StudentService studentService;

  @Override
  public StudentResponse getStudentById(UUID studentId, JwtUser jwtUser) {
    requireNonNull(studentId, "studentId must not be null");
    requireNonNull(jwtUser, "jwtUser must not be null");
    log.debug("Fetching student by id={} for user={}", studentId, jwtUser.userId());
    return studentService.getStudentById(studentId, jwtUser);
  }

  @Override
  public List<StudentResponse> getStudentsByIds(List<UUID> studentIds, JwtUser jwtUser) {
    requireNonNull(studentIds, "studentIds must not be null");
    requireNonNull(jwtUser, "jwtUser must not be null");
    log.debug("Fetching students by ids={} for user={}", studentIds, jwtUser.userId());
    return studentService.getStudentsByIds(studentIds, jwtUser);
  }
}
