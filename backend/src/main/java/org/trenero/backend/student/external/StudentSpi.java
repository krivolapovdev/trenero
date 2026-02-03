package org.trenero.backend.student.external;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.trenero.backend.common.response.StudentResponse;
import org.trenero.backend.common.security.JwtUser;

public interface StudentSpi {
  List<StudentResponse> getAllStudents(JwtUser jwtUser);

  StudentResponse getStudentById(UUID studentId, JwtUser jwtUser);

  Map<UUID, List<StudentResponse>> getStudentsByIds(List<UUID> studentIds, JwtUser jwtUser);
}
