package tech.trenero.backend.student.external;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.common.security.JwtUser;

public interface StudentSpi {
  List<StudentResponse> getStudents(JwtUser jwtUser);

  StudentResponse getStudentById(UUID studentId, JwtUser jwtUser);

  List<StudentResponse> getStudentsByGroupId(UUID groupId, JwtUser jwtUser);

  Map<UUID, List<StudentResponse>> getStudentsByGroupIds(List<UUID> groupIds, JwtUser jwtUser);

  void setGroupIdToStudents(UUID groupId, List<UUID> studentIds, JwtUser jwtUser);

  void removeGroupFromStudents(UUID groupId, JwtUser jwtUser);
}
