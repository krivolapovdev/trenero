package tech.trenero.backend.student.external;

import java.util.List;
import java.util.UUID;
import tech.trenero.backend.common.dto.StudentDto;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.common.security.JwtUser;

public interface StudentSpi {
  StudentResponse getStudentById(UUID studentId, JwtUser jwtUser);

  List<StudentDto> getStudentsByGroupId(UUID groupId, JwtUser jwtUser);
}
