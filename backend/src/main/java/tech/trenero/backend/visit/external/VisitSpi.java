package tech.trenero.backend.visit.external;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import tech.trenero.backend.common.domain.StudentVisit;
import tech.trenero.backend.common.request.CreateVisitRequest;
import tech.trenero.backend.common.response.VisitResponse;
import tech.trenero.backend.common.security.JwtUser;

public interface VisitSpi {
  List<VisitResponse> getVisitsByStudentId(UUID studentId, JwtUser jwtUser);

  Map<UUID, List<VisitResponse>> getVisitsByStudentIds(List<UUID> studentIds, JwtUser jwtUser);

  List<VisitResponse> getVisitsByLessonId(UUID lessonId, JwtUser jwtUser);

  VisitResponse getVisitByLessonIdAndStudentId(UUID lessonId, UUID studentId, JwtUser jwtUser);

  void removeVisitsByLessonId(UUID lessonId, JwtUser jwtUser);

  void updateVisitsByLessonId(UUID lessonId, List<StudentVisit> visits, JwtUser jwtUser);

  VisitResponse createVisit(CreateVisitRequest request, JwtUser jwtUser);

  void createVisits(UUID lessonId, List<StudentVisit> studentVisitList, JwtUser jwtUser);
}
