package tech.trenero.backend.student.external;

import java.util.List;
import java.util.UUID;
import tech.trenero.backend.common.dto.StudentDto;
import tech.trenero.backend.common.security.JwtUser;

public interface StudentSpi {
  List<StudentDto> getStudentsByGroupId(UUID groupId, JwtUser jwtUser);
}
