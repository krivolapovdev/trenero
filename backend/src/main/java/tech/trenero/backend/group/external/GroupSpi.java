package tech.trenero.backend.group.external;

import java.util.List;
import java.util.UUID;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.security.JwtUser;

public interface GroupSpi {
  GroupResponse getGroupById(UUID groupId, JwtUser jwtUser);

  List<GroupResponse> getGroupsByStudentId(UUID studentId, JwtUser jwtUser);

  void assignGroupsToStudent(UUID studentId, List<UUID> studentGroups, JwtUser jwtUser);
}
