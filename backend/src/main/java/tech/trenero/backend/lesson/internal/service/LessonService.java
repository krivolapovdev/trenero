package tech.trenero.backend.lesson.internal.service;

import graphql.schema.DataFetchingEnvironment;
import jakarta.persistence.EntityNotFoundException;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.attendance.external.AttendanceSpi;
import tech.trenero.backend.codegen.types.CreateAttendanceInput;
import tech.trenero.backend.codegen.types.CreateLessonInput;
import tech.trenero.backend.codegen.types.Group;
import tech.trenero.backend.codegen.types.UpdateLessonInput;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;
import tech.trenero.backend.lesson.internal.entity.Lesson;
import tech.trenero.backend.lesson.internal.mapper.LessonMapper;
import tech.trenero.backend.lesson.internal.repository.LessonRepository;

@Service
@Slf4j
@RequiredArgsConstructor
public class LessonService {
  private final LessonRepository lessonRepository;
  private final LessonMapper lessonMapper;
  @Lazy private final AttendanceSpi attendanceSpi;
  @Lazy private final GroupSpi groupSpi;

  @Transactional(readOnly = true)
  public List<tech.trenero.backend.codegen.types.Lesson> getAllLessons(JwtUser jwtUser) {
    log.info("Getting all lessons for ownerId={}", jwtUser.userId());
    return lessonRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(lessonMapper::toGraphql)
        .toList();
  }

  @Transactional(readOnly = true)
  public Optional<tech.trenero.backend.codegen.types.Lesson> findLessonById(
      UUID lessonId, JwtUser jwtUser) {
    log.info("Getting lesson by id={} for ownerId={}", lessonId, jwtUser.userId());
    return lessonRepository
        .findByIdAndOwnerId(lessonId, jwtUser.userId())
        .map(lessonMapper::toGraphql);
  }

  @Transactional(readOnly = true)
  public List<tech.trenero.backend.codegen.types.Lesson> getLessonsByGroupId(
      UUID groupId, JwtUser jwtUser) {
    log.info("Getting lessons by groupId={} for ownerId={}", groupId, jwtUser.userId());
    return lessonRepository.findAllByGroupIdAndOwnerId(groupId, jwtUser.userId()).stream()
        .map(lessonMapper::toGraphql)
        .toList();
  }

  @Transactional
  public tech.trenero.backend.codegen.types.Lesson createLesson(
      CreateLessonInput input, JwtUser jwtUser) {
    log.info(
        "Creating lesson for groupId='{}', startDateTime={}, ownerId={}",
        input.getGroupId(),
        input.getStartDateTime(),
        jwtUser.userId());

    groupSpi.getGroupById(input.getGroupId(), jwtUser);

    Optional<Group> groupById = groupSpi.findGroupById(input.getGroupId(), jwtUser);

    if (groupById.isEmpty()) {
      throw new EntityNotFoundException("Group with id=" + input.getGroupId() + " not found");
    }

    Lesson lesson = lessonMapper.toLesson(input, jwtUser.userId());
    Lesson savedLesson = saveLesson(lesson);

    List<CreateAttendanceInput> attendanceInputList =
        input.getStudents().stream()
            .map(
                status ->
                    new CreateAttendanceInput(
                        savedLesson.getId(), status.getStudentId(), status.getPresent()))
            .toList();

    attendanceSpi.createAttendances(
        savedLesson.getId(), input.getGroupId(), attendanceInputList, jwtUser);

    return lessonMapper.toGraphql(savedLesson);
  }

  @Transactional
  public Optional<tech.trenero.backend.codegen.types.Lesson> updateLesson(
      UUID lessonId,
      UpdateLessonInput input,
      DataFetchingEnvironment environment,
      JwtUser jwtUser) {
    log.info("Editing lesson by lessonId={} for ownerId={}", lessonId, jwtUser.userId());

    if (input.hasStudents()) {
      List<CreateAttendanceInput> attendanceInputList =
          input.getStudents().stream()
              .map(
                  status ->
                      new CreateAttendanceInput(
                          lessonId, status.getStudentId(), status.getPresent()))
              .toList();

      attendanceSpi.editAttendancesByLessonId(lessonId, attendanceInputList, jwtUser);
    }

    return lessonRepository
        .findByIdAndOwnerId(lessonId, jwtUser.userId())
        .map(lesson -> lessonMapper.updateLesson(lesson, input, environment))
        .map(this::saveLesson)
        .map(lessonMapper::toGraphql);
  }

  @Transactional
  public Optional<tech.trenero.backend.codegen.types.Lesson> softDeleteLesson(
      UUID lessonId, JwtUser jwtUser) {
    log.info("Soft deleting lesson: {}", lessonId);

    attendanceSpi.removeAttendancesByLessonId(lessonId, jwtUser);

    return lessonRepository
        .findByIdAndOwnerId(lessonId, jwtUser.userId())
        .map(
            lesson -> {
              lesson.setDeletedAt(OffsetDateTime.now());
              return saveLesson(lesson);
            })
        .map(lessonMapper::toGraphql);
  }

  private Lesson saveLesson(Lesson lesson) {
    log.info("Saving lesson: {}", lesson);
    return lessonRepository.saveAndFlush(lesson);
  }
}
