package tech.trenero.backend.student.internal.spi;

import java.util.List;
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
}
