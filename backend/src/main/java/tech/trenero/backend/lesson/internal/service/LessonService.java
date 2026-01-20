package tech.trenero.backend.lesson.internal.service;

import jakarta.persistence.EntityNotFoundException;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.response.LessonResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;
import tech.trenero.backend.lesson.external.LessonSpi;
import tech.trenero.backend.lesson.internal.entity.Lesson;
import tech.trenero.backend.lesson.internal.mapper.LessonMapper;
import tech.trenero.backend.lesson.internal.repository.LessonRepository;
import tech.trenero.backend.lesson.internal.request.CreateLessonRequest;
import tech.trenero.backend.lesson.internal.request.UpdateLessonRequest;
import tech.trenero.backend.visit.external.VisitSpi;

@Service
@Slf4j
@RequiredArgsConstructor
public class LessonService implements LessonSpi {
  private final LessonRepository lessonRepository;
  private final LessonMapper lessonMapper;
  @Lazy private final VisitSpi visitSpi;
  @Lazy private final GroupSpi groupSpi;

  @Transactional(readOnly = true)
  public List<LessonResponse> getAllLessons(JwtUser jwtUser) {
    log.info("Getting all lessons for ownerId={}", jwtUser.userId());
    return lessonRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(lessonMapper::toResponse)
        .toList();
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
  public List<LessonResponse> getLessonsByGroupId(UUID groupId, JwtUser jwtUser) {
    log.info("Getting lessons by groupId={} for ownerId={}", groupId, jwtUser.userId());
    return lessonRepository.findAllByGroupIdAndOwnerId(groupId, jwtUser.userId()).stream()
        .map(lessonMapper::toResponse)
        .toList();
  }

  @Transactional
  public LessonResponse createLesson(CreateLessonRequest request, JwtUser jwtUser) {
    log.info(
        "Creating lesson for groupId='{}', startDateTime={}, ownerId={}",
        request.groupId(),
        request.startDateTime(),
        jwtUser.userId());

    groupSpi.getGroupById(request.groupId(), jwtUser);

    Lesson lesson = lessonMapper.toLesson(request, jwtUser.userId());
    Lesson savedLesson = saveLesson(lesson);

    //    List<CreateVisitRequest> visitInputList =
    //        request.students().stream()
    //            .map(
    //                status ->
    //                    new CreateVisitRequest(
    //                        savedLesson.getId(), status.studentId(), status.present()))
    //            .toList();

    //    visitSpi.createVisits(savedLesson.getId(), request.groupId(), visitInputList, jwtUser);

    return lessonMapper.toResponse(savedLesson);
  }

  @Transactional
  public LessonResponse updateLesson(UUID lessonId, UpdateLessonRequest request, JwtUser jwtUser) {
    log.info("Editing lesson by lessonId={} for ownerId={}", lessonId, jwtUser.userId());

    //    if (request.students().isPresent()) {
    //      List<CreateVisitRequest> visitInputList =
    //          request.students().stream()
    //              .map(status -> new CreateVisitRequest(lessonId, status.studentId(),
    // status.present()))
    //              .toList();
    //
    //      visitSpi.editVisitsByLessonId(lessonId, visitInputList, jwtUser);
    //    }

    return lessonRepository
        .findByIdAndOwnerId(lessonId, jwtUser.userId())
        .map(lesson -> lessonMapper.updateLesson(lesson, request))
        .map(this::saveLesson)
        .map(lessonMapper::toResponse)
        .orElseThrow(() -> new EntityNotFoundException("Lesson not found for id=" + lessonId));
  }

  @Transactional
  public void softDeleteLesson(UUID lessonId, JwtUser jwtUser) {
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
