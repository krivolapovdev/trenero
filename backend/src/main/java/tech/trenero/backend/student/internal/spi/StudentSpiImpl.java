package tech.trenero.backend.student.internal.spi;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.dto.StudentDto;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.student.external.StudentSpi;
import tech.trenero.backend.student.internal.service.StudentService;

@Component
@RequiredArgsConstructor
public class StudentSpiImpl implements StudentSpi {
  private final StudentService studentService;

  @Override
  public List<StudentDto> getStudentsByGroupId(UUID groupId, JwtUser jwtUser) {
    if (groupId == null || jwtUser == null) {
      return List.of();
    }

    return studentService.getStudentsByGroupId(groupId, jwtUser);
  }

  @Override
  public Optional<StudentDto> getStudentById(UUID studentId, JwtUser jwtUser) {
    if (studentId == null || jwtUser == null) {
      return Optional.empty();
    }

    return studentService.getStudentById(studentId, jwtUser);
  }

  @Override
  public void setGroupIdToStudents(UUID groupId, List<UUID> studentIds, JwtUser jwtUser) {
    if (groupId == null || studentIds == null || studentIds.isEmpty() || jwtUser == null) {
      return;
    }

    studentService.setGroupIdToStudents(groupId, studentIds, jwtUser);
  }
}
