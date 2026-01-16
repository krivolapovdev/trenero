package tech.trenero.backend.student.external;

import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import tech.trenero.backend.codegen.types.Student;
import tech.trenero.backend.common.security.JwtUser;

public interface StudentSpi {
  List<Student> getStudentsByGroupId(UUID groupId, JwtUser jwtUser);

  Optional<Student> findStudentById(UUID studentId, JwtUser jwtUser);

  @SuppressWarnings("UnusedReturnValue")
  Student getStudentById(UUID studentId, JwtUser jwtUser) throws EntityNotFoundException;

  @SuppressWarnings("UnusedReturnValue")
  List<Student> getStudentsByIds(List<UUID> studentIds, JwtUser jwtUser)
      throws EntityNotFoundException;

  void assignGroupToStudents(UUID groupId, List<UUID> studentIds, JwtUser jwtUser);

  void editStudentsGroup(UUID groupId, List<UUID> studentIds, JwtUser jwtUser);

  void removeGroupFromStudents(UUID groupId, JwtUser jwtUser);
}
