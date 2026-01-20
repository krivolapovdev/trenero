package tech.trenero.backend.student.external;

import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import java.util.UUID;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.common.security.JwtUser;

public interface StudentSpi {
  StudentResponse getStudentById(UUID studentId, JwtUser jwtUser) throws EntityNotFoundException;

  void assignGroupToStudents(UUID groupId, List<UUID> studentIds, JwtUser jwtUser);

  void editStudentsGroup(UUID groupId, List<UUID> studentIds, JwtUser jwtUser);

  void removeGroupFromStudents(UUID groupId, JwtUser jwtUser);
}
