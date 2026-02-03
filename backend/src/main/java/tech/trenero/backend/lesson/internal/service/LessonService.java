package tech.trenero.backend.lesson.internal.service;

import jakarta.persistence.EntityNotFoundException;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.domain.StudentVisit;
import tech.trenero.backend.common.domain.VisitStatus;
import tech.trenero.backend.common.response.GroupStudentResponse;
import tech.trenero.backend.common.response.LessonResponse;
import tech.trenero.backend.common.response.VisitResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;
import tech.trenero.backend.group.external.GroupStudentSpi;
import tech.trenero.backend.lesson.external.LessonSpi;
import tech.trenero.backend.lesson.internal.domain.Lesson;
import tech.trenero.backend.lesson.internal.mapper.LessonMapper;
import tech.trenero.backend.lesson.internal.repository.LessonRepository;
import tech.trenero.backend.lesson.internal.request.CreateLessonRequest;
import tech.trenero.backend.lesson.internal.request.UpdateLessonRequest;
import tech.trenero.backend.lesson.internal.response.LessonDetailsResponse;
import tech.trenero.backend.visit.external.VisitSpi;

@Service
@Slf4j
@RequiredArgsConstructor
public class LessonService implements LessonSpi {
  @Lazy private final LessonRepository lessonRepository;
  @Lazy private final LessonMapper lessonMapper;
  @Lazy private final LessonService self;
  @Lazy private final VisitSpi visitSpi;
  @Lazy private final GroupStudentSpi groupStudentSpi;
  @Lazy private final GroupSpi groupSpi;

  @Transactional(readOnly = true)
  public List<LessonResponse> getAllLessons(JwtUser jwtUser) {
    log.info("Getting all lessons for ownerId={}", jwtUser.userId());
    return lessonRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(lessonMapper::toResponse)
        .toList();
  }

  @Override
  @Transactional(readOnly = true)
  public Optional<LessonResponse> getLastGroupLesson(UUID groupId, JwtUser jwtUser) {
    log.info("Getting last lesson for ownerId={}", jwtUser.userId());
    return lessonRepository
        .findLastGroupLesson(groupId, jwtUser.userId())
        .map(lessonMapper::toResponse);
  }

  @Override
  @Transactional(readOnly = true)
  public Map<UUID, LessonResponse> getLastGroupLessonsByGroupIds(
      List<UUID> groupIds, JwtUser jwtUser) {
    log.info("Getting last lessons for {} groups, ownerId={}", groupIds.size(), jwtUser.userId());

    return lessonRepository.findLastLessonsByGroupIdsAndOwnerId(groupIds, jwtUser.userId()).stream()
        .map(lessonMapper::toResponse)
        .collect(Collectors.toMap(LessonResponse::groupId, Function.identity()));
  }

  @Transactional(readOnly = true)
  public LessonResponse getLessonById(UUID lessonId, JwtUser jwtUser) {
    log.info("Getting lesson by id={} for ownerId={}", lessonId, jwtUser.userId());
    return lessonRepository
        .findByIdAndOwnerId(lessonId, jwtUser.userId())
        .map(lessonMapper::toResponse)
        .orElseThrow(() -> new EntityNotFoundException("Lesson not found for id=" + lessonId));
  }

  @Transactional(readOnly = true)
  public LessonDetailsResponse getLessonDetailsById(UUID lessonId, JwtUser jwtUser) {
    log.info("Getting lesson details for lessonId={} and userId={}", lessonId, jwtUser.userId());

    LessonResponse lesson = self.getLessonById(lessonId, jwtUser);
    List<VisitResponse> visits = visitSpi.getVisitsByLessonId(lessonId, jwtUser);
    List<GroupStudentResponse> groupStudents =
        groupStudentSpi.getStudentsByGroupId(lesson.groupId(), jwtUser);

    return new LessonDetailsResponse(lesson, visits, groupStudents);
  }

  @Transactional(readOnly = true)
  public List<LessonResponse> getLessonsByGroupId(UUID groupId, JwtUser jwtUser) {
    log.info("Getting lessons by groupId={} for ownerId={}", groupId, jwtUser.userId());
    return lessonRepository.findAllByGroupIdAndOwnerId(groupId, jwtUser.userId()).stream()
        .map(lessonMapper::toResponse)
        .toList();
  }

  @Transactional(readOnly = true)
  public List<VisitResponse> getVisitsByLessonId(UUID lessonId, JwtUser jwtUser) {
    return visitSpi.getVisitsByLessonId(lessonId, jwtUser);
  }

  @Transactional
  public LessonResponse createLesson(CreateLessonRequest request, JwtUser jwtUser) {
    log.info(
        "Creating lesson for groupId='{}', startDateTime={}, ownerId={}",
        request.groupId(),
        request.startDateTime(),
        jwtUser.userId());

    Lesson lesson = lessonMapper.toLesson(request, jwtUser.userId());
    Lesson savedLesson = saveLesson(lesson);

    List<StudentVisit> studentVisitList =
        groupStudentSpi.getStudentsByGroupId(request.groupId(), jwtUser).stream()
            .filter(Objects::nonNull)
            .map(
                res -> {
                  VisitStatus status =
                      request.students().stream()
                          .filter(Objects::nonNull)
                          .filter(req -> req.studentId().equals(res.studentId()))
                          .findFirst()
                          .map(StudentVisit::status)
                          .orElse(VisitStatus.UNMARKED);

                  return new StudentVisit(res.studentId(), status);
                })
            .toList();

    visitSpi.createVisits(lesson.getId(), studentVisitList, jwtUser);

    return lessonMapper.toResponse(savedLesson);
  }

  @Transactional
  public LessonResponse updateLesson(UUID lessonId, UpdateLessonRequest request, JwtUser jwtUser) {
    log.info("Updating lesson by lessonId={} for ownerId={}", lessonId, jwtUser.userId());

    if (request.students() != null && !request.students().isEmpty()) {
      List<StudentVisit> visitUpdateList =
          request.students().stream()
              .filter(Objects::nonNull)
              .map(req -> new StudentVisit(req.studentId(), req.status()))
              .toList();

      visitSpi.updateVisitsByLessonId(lessonId, visitUpdateList, jwtUser);
    }

    return lessonRepository
        .findByIdAndOwnerId(lessonId, jwtUser.userId())
        .map(lesson -> lessonMapper.updateLesson(lesson, request))
        .map(this::saveLesson)
        .map(lessonMapper::toResponse)
        .orElseThrow(() -> new EntityNotFoundException("Lesson not found for id=" + lessonId));
  }

  @Override
  public void deleteLesson(UUID lessonId, JwtUser jwtUser) {
    softDeleteLesson(lessonId, jwtUser);
  }

  private void softDeleteLesson(UUID lessonId, JwtUser jwtUser) {
    log.info("Soft deleting lesson: {}", lessonId);

    visitSpi.removeVisitsByLessonId(lessonId, jwtUser);

    lessonRepository
        .findByIdAndOwnerId(lessonId, jwtUser.userId())
        .map(
            lesson -> {
              lesson.setDeletedAt(OffsetDateTime.now());
              return saveLesson(lesson);
            })
        .orElseThrow(() -> new EntityNotFoundException("Lesson not found for id=" + lessonId));
  }

  private Lesson saveLesson(Lesson lesson) {
    log.info("Saving lesson: {}", lesson);
    return lessonRepository.saveAndFlush(lesson);
  }
}
