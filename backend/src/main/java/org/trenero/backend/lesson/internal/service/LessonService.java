package org.trenero.backend.lesson.internal.service;

import static org.trenero.backend.common.exception.ExceptionUtils.entityNotFoundSupplier;

import java.time.OffsetDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.trenero.backend.common.domain.StudentVisit;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.lesson.external.response.LessonResponse;
import org.trenero.backend.lesson.external.spi.LessonSpi;
import org.trenero.backend.lesson.internal.domain.Lesson;
import org.trenero.backend.lesson.internal.mapper.LessonMapper;
import org.trenero.backend.lesson.internal.repository.LessonRepository;
import org.trenero.backend.lesson.internal.request.CreateLessonRequest;
import org.trenero.backend.lesson.internal.request.UpdateLessonRequest;
import org.trenero.backend.lesson.internal.response.LessonDetailsResponse;
import org.trenero.backend.student.external.response.StudentResponse;
import org.trenero.backend.student.external.spi.StudentSpi;
import org.trenero.backend.visit.external.response.VisitResponse;
import org.trenero.backend.visit.external.spi.VisitSpi;

@Service
@Slf4j
@RequiredArgsConstructor
public class LessonService implements LessonSpi {

  private final LessonRepository lessonRepository;
  private final LessonMapper lessonMapper;

  @Lazy private final LessonService self;
  @Lazy private final VisitSpi visitSpi;
  @Lazy private final StudentSpi studentSpi;

  @Transactional(readOnly = true)
  public @NonNull LessonResponse getLessonById(@NonNull UUID lessonId, @NonNull JwtUser jwtUser) {
    log.info("Getting lesson by id: lessonId={}; user={}", lessonId, jwtUser);
    return lessonRepository
        .findByIdAndOwnerId(lessonId, jwtUser.id())
        .map(lessonMapper::toResponse)
        .orElseThrow(entityNotFoundSupplier(Lesson.class, lessonId, jwtUser));
  }

  @Transactional(readOnly = true)
  public LessonDetailsResponse getLessonDetailsById(UUID lessonId, JwtUser jwtUser) {
    log.info("Getting lesson details: lessonId={}; user={}", lessonId, jwtUser);

    LessonResponse lesson = self.getLessonById(lessonId, jwtUser);
    List<VisitResponse> visits = visitSpi.getVisitsByLessonId(lessonId, jwtUser);

    // The students of the visits are not necessarily the students of the group of the lesson: a
    // student that left the group keeps their visit, so the students are loaded on their own to
    // keep them visible in the lesson.
    List<UUID> studentIds = visits.stream().map(VisitResponse::getStudentId).distinct().toList();

    Map<UUID, StudentResponse> studentsMap =
        studentIds.isEmpty() ? Map.of() : studentSpi.getStudentsByIds(studentIds, jwtUser);

    List<StudentResponse> students =
        studentIds.stream().map(studentsMap::get).filter(Objects::nonNull).toList();

    return new LessonDetailsResponse(lesson, visits, students);
  }

  @Transactional(readOnly = true)
  public @NonNull List<LessonResponse> getLessonsByGroupId(
      @NonNull UUID groupId, @NonNull JwtUser jwtUser) {
    log.info("Getting lessons by group id: groupId={}; user={}", groupId, jwtUser);
    return lessonRepository.findAllByGroupIdAndOwnerId(groupId, jwtUser.id()).stream()
        .map(lessonMapper::toResponse)
        .toList();
  }

  @Override
  @Transactional(readOnly = true)
  public @NonNull Map<UUID, LessonResponse> getLessonsByIds(
      @NonNull List<UUID> lessonIds, @NonNull JwtUser jwtUser) {
    log.info("Getting lessons by ids: lessonIds={}; user={}", lessonIds, jwtUser);

    if (lessonIds.isEmpty()) {
      return Map.of();
    }

    return lessonRepository.findAllByIdsAndOwnerId(lessonIds, jwtUser.id()).stream()
        .map(lessonMapper::toResponse)
        .collect(Collectors.toMap(LessonResponse::getId, Function.identity()));
  }

  @Transactional
  public LessonResponse createLesson(CreateLessonRequest request, JwtUser jwtUser) {
    log.info("Creating lesson: request={}; user={}", request, jwtUser);

    Lesson lesson = lessonMapper.toLesson(request, jwtUser.id());
    Lesson savedLesson = saveLesson(lesson);

    visitSpi.createVisits(lesson.getId(), buildStudentVisits(request), jwtUser);

    return lessonMapper.toResponse(savedLesson);
  }

  /**
   * The visits to store for a new lesson.
   *
   * <p>Only the students that were sent are stored: a student that is left unmarked carries no
   * visit at all, so no row is created for them. The last entry of a student wins, which keeps the
   * list free of duplicates while preserving the order it was sent in.
   */
  private List<StudentVisit> buildStudentVisits(CreateLessonRequest request) {
    Map<UUID, StudentVisit> requestStudentMap =
        request.students().stream()
            .filter(Objects::nonNull)
            .collect(
                Collectors.toMap(
                    StudentVisit::studentId,
                    Function.identity(),
                    (_, second) -> second,
                    LinkedHashMap::new));

    return List.copyOf(requestStudentMap.values());
  }

  @Transactional
  public LessonResponse updateLesson(UUID lessonId, UpdateLessonRequest request, JwtUser jwtUser) {
    log.info("Updating lesson: lessonId={}; request={}; user={}", lessonId, request, jwtUser);

    if (request.students() != null) {
      List<StudentVisit> visitUpdateList =
          request.students().stream()
              .filter(Objects::nonNull)
              .map(req -> new StudentVisit(req.studentId(), req.status(), req.type()))
              .toList();

      visitSpi.updateVisitsByLessonId(lessonId, visitUpdateList, jwtUser);
    }

    return lessonRepository
        .findByIdAndOwnerId(lessonId, jwtUser.id())
        .map(lesson -> lessonMapper.updateLesson(lesson, request))
        .map(this::saveLesson)
        .map(lessonMapper::toResponse)
        .orElseThrow(entityNotFoundSupplier(Lesson.class, lessonId, jwtUser));
  }

  @Override
  @Transactional
  public void deleteLesson(@NonNull UUID lessonId, @NonNull JwtUser jwtUser) {
    log.info("Deleting lesson: lessonId={}; user={}", lessonId, jwtUser);

    visitSpi.removeVisitsByLessonId(lessonId, jwtUser);

    Lesson lesson =
        lessonRepository
            .findByIdAndOwnerId(lessonId, jwtUser.id())
            .orElseThrow(entityNotFoundSupplier(Lesson.class, lessonId, jwtUser));

    lessonRepository.delete(lesson);
  }

  @Override
  public @NonNull List<LessonResponse> getLessonsByGroupIdAndDateRange(
      @NonNull UUID groupId,
      @NonNull OffsetDateTime from,
      @NonNull OffsetDateTime to,
      @NonNull JwtUser jwtUser) {
    log.info(
        "Getting lessons by group id and date range: groupId={}; from={}; to={}; user={}",
        groupId,
        from,
        to,
        jwtUser);

    return lessonRepository
        .findAllByGroupIdAndOwnerIdAndDateBetween(groupId, jwtUser.id(), from, to)
        .stream()
        .map(lessonMapper::toResponse)
        .toList();
  }

  private Lesson saveLesson(Lesson lesson) {
    log.info("Saving lesson: lesson={}", lesson);
    return lessonRepository.saveAndFlush(lesson);
  }
}
