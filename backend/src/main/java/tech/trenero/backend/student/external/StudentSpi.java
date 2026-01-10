package tech.trenero.backend.student.external;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import tech.trenero.backend.common.dto.StudentDto;
import tech.trenero.backend.common.security.JwtUser;

public interface StudentSpi {
  List<StudentDto> getStudentsByGroupId(UUID groupId, JwtUser jwtUser);

  Optional<StudentDto> getStudentById(UUID studentId, JwtUser jwtUser);

  void assignGroupToStudents(UUID groupId, List<UUID> studentIds, JwtUser jwtUser);

  void updateStudentsGroup(UUID groupId, List<UUID> studentIds, JwtUser jwtUser);
}
