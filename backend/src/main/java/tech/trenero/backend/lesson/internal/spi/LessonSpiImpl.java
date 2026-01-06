package tech.trenero.backend.lesson.internal.spi;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.dto.LessonDto;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.lesson.external.LessonSpi;
import tech.trenero.backend.lesson.internal.service.LessonService;

@Component
@RequiredArgsConstructor
public class LessonSpiImpl implements LessonSpi {
  private final LessonService lessonService;

  @Override
  public List<LessonDto> getLessonsByGroupId(UUID groupId, JwtUser jwtUser) {
    if (groupId == null || jwtUser == null) {
      return List.of();
    }

    return lessonService.getLessonsByGroupId(groupId, jwtUser);
  }

  @Override
  public Optional<LessonDto> getLastLessonByGroupId(UUID groupId, JwtUser jwtUser) {
    if (groupId == null || jwtUser == null) {
      return Optional.empty();
    }

    return lessonService.getLastLessonByGroupId(groupId, jwtUser);
  }

  @Override
  public Optional<LessonDto> getLessonById(UUID lessonId, JwtUser jwtUser) {
    if (lessonId == null || jwtUser == null) {
      return Optional.empty();
    }

    return lessonService.getLessonById(lessonId, jwtUser);
  }
}
