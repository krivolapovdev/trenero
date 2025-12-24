package tech.trenero.backend.lesson.external;

import java.util.List;
import java.util.UUID;
import tech.trenero.backend.common.dto.LessonDto;
import tech.trenero.backend.common.security.JwtUser;

public interface LessonSpi {
  List<LessonDto> getLessonsByGroupId(UUID groupId, JwtUser jwtUser);
}
