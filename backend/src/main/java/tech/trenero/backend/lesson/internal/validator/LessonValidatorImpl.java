package tech.trenero.backend.lesson.internal.validator;

import jakarta.persistence.EntityNotFoundException;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.lesson.external.LessonValidator;
import tech.trenero.backend.lesson.internal.service.LessonService;

@Component
@RequiredArgsConstructor
public class LessonValidatorImpl implements LessonValidator {
  private final LessonService lessonService;

  @Override
  public void validateLessonIsPresentAndActive(UUID lessonId, JwtUser jwtUser)
      throws EntityNotFoundException {
    if (lessonId == null) {
      return;
    }

    lessonService
        .getLessonById(lessonId, jwtUser)
        .orElseThrow(() -> new EntityNotFoundException("Lesson not found by id: " + lessonId));
  }
}
