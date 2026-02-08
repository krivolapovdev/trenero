package org.trenero.backend.lesson.external;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import org.trenero.backend.common.response.LessonResponse;
import org.trenero.backend.common.security.JwtUser;

public interface LessonSpi {
  List<LessonResponse> getAllLessons(JwtUser jwtUser);

  Optional<LessonResponse> getLastGroupLesson(UUID groupId, JwtUser jwtUser);

  Map<UUID, LessonResponse> getLastGroupLessonsByGroupIds(List<UUID> groupIds, JwtUser jwtUser);

  LessonResponse getLessonById(UUID lessonId, JwtUser jwtUser);

  List<LessonResponse> getLessonsByGroupId(UUID groupId, JwtUser jwtUser);

  Map<UUID, LessonResponse> getLessonsByIds(List<UUID> ids, JwtUser jwtUser);

  void deleteLesson(UUID lessonId, JwtUser jwtUser);
}
