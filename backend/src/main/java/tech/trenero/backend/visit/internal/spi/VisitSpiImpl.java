package tech.trenero.backend.visit.internal.spi;

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;
import tech.trenero.backend.codegen.types.CreateVisitInput;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.student.external.StudentSpi;
import tech.trenero.backend.visit.external.VisitSpi;
import tech.trenero.backend.visit.internal.entity.Visit;
import tech.trenero.backend.visit.internal.mapper.VisitMapper;
import tech.trenero.backend.visit.internal.service.VisitService;

@Component
@RequiredArgsConstructor
public class VisitSpiImpl implements VisitSpi {
  private static final String JWT_USER_MUST_NOT_BE_NULL = "jwtUser must not be null";
  private static final String LESSON_ID_MUST_NOT_BE_NULL = "lessonId must not be null";
  private final VisitService visitService;
  private final VisitMapper visitMapper;
  @Lazy private final StudentSpi studentSpi;

  @Override
  public List<tech.trenero.backend.codegen.types.Visit> getVisitsByStudentId(
      UUID studentId, JwtUser jwtUser) {
    Objects.requireNonNull(studentId, "studentId must not be null");
    Objects.requireNonNull(jwtUser, JWT_USER_MUST_NOT_BE_NULL);

    return visitService.getVisitsByStudentId(studentId, jwtUser);
  }

  @Override
  public List<tech.trenero.backend.codegen.types.Visit> getVisitsByLessonId(
      UUID lessonId, JwtUser jwtUser) {
    Objects.requireNonNull(lessonId, LESSON_ID_MUST_NOT_BE_NULL);
    Objects.requireNonNull(jwtUser, JWT_USER_MUST_NOT_BE_NULL);

    return visitService.getVisitsByLessonId(lessonId, jwtUser);
  }

  @Override
  public void createVisits(
      UUID lessonId, UUID groupId, List<CreateVisitInput> visitInputList, JwtUser jwtUser) {
    Objects.requireNonNull(lessonId, LESSON_ID_MUST_NOT_BE_NULL);
    Objects.requireNonNull(groupId, "groupId must not be null");
    Objects.requireNonNull(visitInputList, "visitInputList must not be null");
    Objects.requireNonNull(jwtUser, JWT_USER_MUST_NOT_BE_NULL);

    if (visitInputList.isEmpty()) {
      return;
    }

    List<UUID> studentIds = visitInputList.stream().map(CreateVisitInput::getStudentId).toList();

    studentSpi.getStudentsByIds(studentIds, jwtUser);

    List<Visit> visits =
        visitInputList.stream().map(input -> visitMapper.toVisit(input, jwtUser.userId())).toList();

    visitService.saveVisitList(visits);
  }

  @Override
  public void editVisitsByLessonId(UUID lessonId, List<CreateVisitInput> input, JwtUser jwtUser) {
    Objects.requireNonNull(lessonId, LESSON_ID_MUST_NOT_BE_NULL);
    Objects.requireNonNull(input, "input must not be null");
    Objects.requireNonNull(jwtUser, JWT_USER_MUST_NOT_BE_NULL);

    if (input.isEmpty()) {
      return;
    }

    List<UUID> studentIds = input.stream().map(CreateVisitInput::getStudentId).toList();
    studentSpi.getStudentsByIds(studentIds, jwtUser);

    Map<UUID, tech.trenero.backend.codegen.types.Visit> existingMap =
        visitService.getVisitsByLessonId(lessonId, jwtUser).stream()
            .collect(Collectors.toMap(a -> a.getStudent().getId(), Function.identity()));

    List<Visit> visitsToSave =
        input.stream()
            .map(
                in -> {
                  tech.trenero.backend.codegen.types.Visit existing =
                      existingMap.get(in.getStudentId());

                  Visit visit = visitMapper.toVisit(in, jwtUser.userId());

                  if (existing != null) {
                    visit.setId(existing.getId());
                  }

                  return visit;
                })
            .toList();

    if (!visitsToSave.isEmpty()) {
      visitService.saveVisitList(visitsToSave);
    }
  }

  @Override
  public void removeVisitsByLessonId(UUID lessonId, JwtUser jwtUser) {
    Objects.requireNonNull(lessonId, LESSON_ID_MUST_NOT_BE_NULL);
    Objects.requireNonNull(jwtUser, JWT_USER_MUST_NOT_BE_NULL);

    visitService.getVisitsByLessonId(lessonId, jwtUser).stream()
        .map(tech.trenero.backend.codegen.types.Visit::getId)
        .forEach(id -> visitService.softDeleteVisit(id, jwtUser));
  }
}
