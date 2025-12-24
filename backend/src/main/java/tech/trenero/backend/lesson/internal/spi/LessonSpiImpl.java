package tech.trenero.backend.lesson.internal.spi;

import java.util.List;
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
    return lessonService.getLessonsByGroupId(groupId, jwtUser);
  }
}
