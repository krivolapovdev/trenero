package tech.trenero.backend.student.external;

import java.util.List;
import java.util.UUID;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.common.security.JwtUser;

public interface StudentSpi {
  StudentResponse getStudentById(UUID id, JwtUser jwtUser);

  List<StudentResponse> getStudentsByGroupId(UUID groupId, JwtUser jwtUser);
}
