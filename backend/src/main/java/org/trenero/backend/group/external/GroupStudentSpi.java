package org.trenero.backend.group.external;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.trenero.backend.common.response.GroupStudentResponse;
import org.trenero.backend.common.security.JwtUser;

public interface GroupStudentSpi {
  List<GroupStudentResponse> getStudentsByGroupId(UUID groupId, JwtUser jwtUser);

  List<GroupStudentResponse> getGroupsByStudentId(UUID studentId, JwtUser jwtUser);

  Map<UUID, GroupStudentResponse> getGroupStudentsByStudentIds(
      List<UUID> studentIds, JwtUser jwtUser);

  GroupStudentResponse addStudentToGroup(UUID studentId, UUID groupId, JwtUser jwtUser);

  void removeStudentFromGroup(UUID studentId, UUID groupId, JwtUser jwtUser);
}
