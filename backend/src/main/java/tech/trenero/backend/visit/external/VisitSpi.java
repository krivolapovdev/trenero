package tech.trenero.backend.visit.external;

import java.util.List;
import java.util.UUID;
import tech.trenero.backend.common.response.VisitResponse;
import tech.trenero.backend.common.security.JwtUser;

public interface VisitSpi {
  List<VisitResponse> getVisitsByStudentId(UUID studentId, JwtUser jwtUser);

  List<VisitResponse> getVisitsByLessonId(UUID lessonId, JwtUser jwtUser);

  //
  //  void createVisits(
  //      UUID lessonId, UUID groupId, List<CreateVisitRequest> visitInputList, JwtUser jwtUser);
  //
  //  void editVisitsByLessonId(UUID lessonId, List<CreateVisitRequest> input, JwtUser jwtUser);

  void removeVisitsByLessonId(UUID lessonId, JwtUser jwtUser);
}
