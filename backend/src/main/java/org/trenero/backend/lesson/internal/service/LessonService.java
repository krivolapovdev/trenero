package org.trenero.backend.lesson.internal.service;

import static org.trenero.backend.common.exception.ExceptionUtils.entityNotFoundSupplier;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
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
import org.trenero.backend.common.domain.VisitStatus;
import org.trenero.backend.common.domain.VisitType;
import org.trenero.backend.common.response.GroupStudentResponse;
import org.trenero.backend.common.response.LessonResponse;
import org.trenero.backend.common.response.VisitResponse;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.group.external.GroupStudentSpi;
import org.trenero.backend.lesson.external.LessonSpi;
import org.trenero.backend.lesson.internal.domain.Lesson;
import org.trenero.backend.lesson.internal.mapper.LessonMapper;
import org.trenero.backend.lesson.internal.repository.LessonRepository;
import org.trenero.backend.lesson.internal.request.CreateLessonRequest;
import org.trenero.backend.lesson.internal.request.UpdateLessonRequest;
import org.trenero.backend.lesson.internal.response.LessonDetailsResponse;
import org.trenero.backend.visit.external.VisitSpi;

@Service
@Slf4j
@RequiredArgsConstructor
public class LessonService implements LessonSpi {
  private final LessonRepository lessonRepository;
  private final LessonMapper lessonMapper;

  @Lazy private final LessonService self;
  @Lazy private final VisitSpi visitSpi;
  @Lazy private final GroupStudentSpi groupStudentSpi;

  @Transactional(readOnly = true)
  public @NonNull List<LessonResponse> getAllLessons(@NonNull JwtUser jwtUser) {
    log.info("Getting all lessons: user={}", jwtUser);
    return lessonRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(lessonMapper::toResponse)
        .toList();
  }

  @Override
  @Transactional(readOnly = true)
  public @NonNull Optional<LessonResponse> getLastGroupLesson(
      @NonNull UUID groupId, @NonNull JwtUser jwtUser) {
    log.info("Getting last group lesson: groupId={}; user={}", groupId, jwtUser);
    return lessonRepository
        .findLastGroupLesson(groupId, jwtUser.userId())
        .map(lessonMapper::toResponse);
  }

  @Override
  @Transactional(readOnly = true)
  public @NonNull Map<UUID, LessonResponse> getLastGroupLessonsByGroupIds(
      @NonNull List<UUID> groupIds, @NonNull JwtUser jwtUser) {
    log.info("Getting last group lessons: groupIds={}; user={}", groupIds, jwtUser);
    return lessonRepository.findLastLessonsByGroupIdsAndOwnerId(groupIds, jwtUser.userId()).stream()
        .map(lessonMapper::toResponse)
        .collect(Collectors.toMap(LessonResponse::groupId, Function.identity()));
  }

  @Transactional(readOnly = true)
  public @NonNull LessonResponse getLessonById(@NonNull UUID lessonId, @NonNull JwtUser jwtUser) {
    log.info("Getting lesson by id: lessonId={}; user={}", lessonId, jwtUser);
    return lessonRepository
        .findByIdAndOwnerId(lessonId, jwtUser.userId())
        .map(lessonMapper::toResponse)
        .orElseThrow(entityNotFoundSupplier(Lesson.class, lessonId, jwtUser));
  }

  @Transactional(readOnly = true)
  public LessonDetailsResponse getLessonDetailsById(UUID lessonId, JwtUser jwtUser) {
    log.info("Getting lesson details: lessonId={}; user={}", lessonId, jwtUser);

    LessonResponse lesson = self.getLessonById(lessonId, jwtUser);
    List<VisitResponse> visits = visitSpi.getVisitsByLessonId(lessonId, jwtUser);
    List<GroupStudentResponse> groupStudents =
        groupStudentSpi.getStudentsByGroupId(lesson.groupId(), jwtUser);

    return new LessonDetailsResponse(lesson, visits, groupStudents);
  }

  @Transactional(readOnly = true)
  public @NonNull List<LessonResponse> getLessonsByGroupId(
      @NonNull UUID groupId, @NonNull JwtUser jwtUser) {
    log.info("Getting lessons by group id: groupId={}; user={}", groupId, jwtUser);
    return lessonRepository.findAllByGroupIdAndOwnerId(groupId, jwtUser.userId()).stream()
        .map(lessonMapper::toResponse)
        .toList();
  }

  @Transactional(readOnly = true)
  public @NonNull Map<UUID, List<LessonResponse>> getLessonsByGroupIds(
      @NonNull List<UUID> groupIds, @NonNull JwtUser jwtUser) {
    log.info("Getting lessons by group ids: groupIds={}; user={}", groupIds, jwtUser);

    if (groupIds.isEmpty()) {
      return Map.of();
    }

    return lessonRepository.findAllByGroupIds(groupIds).stream()
        .map(lessonMapper::toResponse)
        .collect(Collectors.groupingBy(LessonResponse::groupId));
  }

  @Transactional(readOnly = true)
  public @NonNull Map<UUID, LessonResponse> getLessonsByIds(
      @NonNull List<UUID> ids, @NonNull JwtUser jwtUser) {
    log.info("Getting lessons by ids: ids={}; user={}", ids, jwtUser);

    if (ids.isEmpty()) {
      return Map.of();
    }

    return lessonRepository.findAllByIdsAndOwnerId(ids, jwtUser.userId()).stream()
        .map(lessonMapper::toResponse)
        .collect(Collectors.toMap(LessonResponse::id, Function.identity()));
  }

  @Transactional
  public LessonResponse createLesson(CreateLessonRequest request, JwtUser jwtUser) {
    log.info("Creating lesson: request={}; user={}", request, jwtUser);

    Lesson lesson = lessonMapper.toLesson(request, jwtUser.userId());
    Lesson savedLesson = saveLesson(lesson);

    Map<UUID, StudentVisit> requestStudentMap =
        request.students().stream()
            .filter(Objects::nonNull)
            .collect(Collectors.toMap(StudentVisit::studentId, Function.identity()));

    List<StudentVisit> studentVisitList =
        groupStudentSpi.getStudentsByGroupId(request.groupId(), jwtUser).stream()
            .map(
                res ->
                    requestStudentMap.getOrDefault(
                        res.studentId(),
                        new StudentVisit(
                            res.studentId(), VisitStatus.UNMARKED, VisitType.UNMARKED)))
            .toList();

    visitSpi.createVisits(lesson.getId(), studentVisitList, jwtUser);

    return lessonMapper.toResponse(savedLesson);
  }

  @Transactional
  public LessonResponse updateLesson(UUID lessonId, UpdateLessonRequest request, JwtUser jwtUser) {
    log.info("Updating lesson: lessonId={}; request={}; user={}", lessonId, request, jwtUser);

    if (request.students() != null && !request.students().isEmpty()) {
      List<StudentVisit> visitUpdateList =
          request.students().stream()
              .filter(Objects::nonNull)
              .map(req -> new StudentVisit(req.studentId(), req.status(), req.type()))
              .toList();

      visitSpi.updateVisitsByLessonId(lessonId, visitUpdateList, jwtUser);
    }

    return lessonRepository
        .findByIdAndOwnerId(lessonId, jwtUser.userId())
        .map(lesson -> lessonMapper.updateLesson(lesson, request))
        .map(this::saveLesson)
        .map(lessonMapper::toResponse)
        .orElseThrow(entityNotFoundSupplier(Lesson.class, lessonId, jwtUser));
  }

  @Override
  public void deleteLesson(@NonNull UUID lessonId, @NonNull JwtUser jwtUser) {
    softDeleteLesson(lessonId, jwtUser);
  }

  private void softDeleteLesson(UUID lessonId, JwtUser jwtUser) {
    log.info("Deleting lesson: lessonId={}; user={}", lessonId, jwtUser);

    visitSpi.removeVisitsByLessonId(lessonId, jwtUser);

    lessonRepository
        .findByIdAndOwnerId(lessonId, jwtUser.userId())
        .map(
            lesson -> {
              lesson.setDeletedAt(OffsetDateTime.now());
              return saveLesson(lesson);
            })
        .orElseThrow(entityNotFoundSupplier(Lesson.class, lessonId, jwtUser));
  }

  private Lesson saveLesson(Lesson lesson) {
    log.info("Saving lesson: lesson={}", lesson);
    return lessonRepository.saveAndFlush(lesson);
  }
}
