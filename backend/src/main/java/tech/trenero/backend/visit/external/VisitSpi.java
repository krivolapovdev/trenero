package tech.trenero.backend.visit.external;

import java.util.List;
import java.util.UUID;
import tech.trenero.backend.codegen.types.CreateVisitInput;
import tech.trenero.backend.codegen.types.Visit;
import tech.trenero.backend.common.security.JwtUser;

public interface VisitSpi {
  List<Visit> getVisitsByStudentId(UUID studentId, JwtUser jwtUser);

  List<Visit> getVisitsByLessonId(UUID lessonId, JwtUser jwtUser);

  void createVisits(
      UUID lessonId, UUID groupId, List<CreateVisitInput> visitInputList, JwtUser jwtUser);

  void editVisitsByLessonId(UUID lessonId, List<CreateVisitInput> input, JwtUser jwtUser);

  void removeVisitsByLessonId(UUID lessonId, JwtUser jwtUser);
}
