package tech.trenero.backend.lesson.internal.spi;

import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import tech.trenero.backend.codegen.types.Lesson;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.lesson.external.LessonSpi;
import tech.trenero.backend.lesson.internal.service.LessonService;

@Component
@RequiredArgsConstructor
public class LessonSpiImpl implements LessonSpi {
  private final LessonService lessonService;

  @Override
  public List<Lesson> getLessonsByGroupId(UUID groupId, JwtUser jwtUser) {
    Objects.requireNonNull(groupId, "groupId must not be null");
    Objects.requireNonNull(jwtUser, "jwtUser must not be null");

    return lessonService.getLessonsByGroupId(groupId, jwtUser);
  }

  @Override
  public Optional<Lesson> findLessonById(UUID lessonId, JwtUser jwtUser) {
    Objects.requireNonNull(lessonId, "lessonId must not be null");
    Objects.requireNonNull(jwtUser, "jwtUser must not be null");

    return lessonService.findLessonById(lessonId, jwtUser);
  }

  @Override
  public Lesson getLessonById(UUID lessonId, JwtUser jwtUser) throws EntityNotFoundException {
    return findLessonById(lessonId, jwtUser)
        .orElseThrow(
            () -> new EntityNotFoundException("Lesson not found: lessonId=%s".formatted(lessonId)));
  }
}
