package tech.trenero.backend.lesson.external;

import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import tech.trenero.backend.codegen.types.Lesson;
import tech.trenero.backend.common.security.JwtUser;

public interface LessonSpi {
  List<Lesson> getLessonsByGroupId(UUID groupId, JwtUser jwtUser);

  Optional<Lesson> findLessonById(UUID lessonId, JwtUser jwtUser);

  @SuppressWarnings("UnusedReturnValue")
  Lesson getLessonById(UUID lessonId, JwtUser jwtUser) throws EntityNotFoundException;
}
