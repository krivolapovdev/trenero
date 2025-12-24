package tech.trenero.backend.lesson.external;

import jakarta.persistence.EntityNotFoundException;
import java.util.UUID;
import tech.trenero.backend.common.security.JwtUser;

public interface LessonValidator {
  void validateLesson(UUID lessonId, JwtUser jwtUser) throws EntityNotFoundException;
}
