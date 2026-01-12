package tech.trenero.backend.lesson.internal.service;

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
import tech.trenero.backend.common.dto.LessonDto;
import tech.trenero.backend.common.input.CreateAttendanceInput;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupValidator;
import tech.trenero.backend.lesson.internal.entity.Lesson;
import tech.trenero.backend.lesson.internal.input.CreateLessonInput;
import tech.trenero.backend.lesson.internal.mapper.LessonMapper;
import tech.trenero.backend.lesson.internal.repository.LessonRepository;

@Service
@Slf4j
@RequiredArgsConstructor
public class LessonService {
  private final LessonRepository lessonRepository;
  private final LessonMapper lessonMapper;
  private final GroupValidator groupValidator;
  @Lazy private final AttendanceSpi attendanceSpi;

  @Transactional(readOnly = true)
  public List<LessonDto> getAllLessons(JwtUser jwtUser) {
    log.info("Getting all lessons for ownerId={}", jwtUser.userId());
    return lessonRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(lessonMapper::toDto)
        .toList();
  }

  @Transactional(readOnly = true)
  public Optional<LessonDto> getLessonById(UUID lessonId, JwtUser jwtUser) {
    log.info("Getting lesson by id={} for ownerId={}", lessonId, jwtUser.userId());
    return lessonRepository.findByIdAndOwnerId(lessonId, jwtUser.userId()).map(lessonMapper::toDto);
  }

  @Transactional
  public LessonDto createLesson(CreateLessonInput input, JwtUser jwtUser) {
    log.info(
        "Creating lesson for groupId='{}', startDateTime={}, ownerId={}",
        input.groupId(),
        input.startDateTime(),
        jwtUser.userId());

    groupValidator.validateGroupIsPresentAndActive(input.groupId(), jwtUser);

    Lesson lesson = lessonMapper.toLesson(input, jwtUser.userId());
    Lesson savedLesson = saveLesson(lesson);

    List<CreateAttendanceInput> attendanceInputList =
        input.students().stream()
            .map(
                status ->
                    new CreateAttendanceInput(
                        savedLesson.getId(), status.studentId(), status.present()))
            .toList();

    attendanceSpi.createAttendances(
        savedLesson.getId(), input.groupId(), attendanceInputList, jwtUser);

    return lessonMapper.toDto(savedLesson);
  }

  @Transactional
  public Optional<LessonDto> editLesson(UUID lessonId, CreateLessonInput input, JwtUser jwtUser) {
    log.info("Editing lesson by lessonId={} for ownerId={}", lessonId, jwtUser.userId());

    List<CreateAttendanceInput> attendanceInputList =
        input.students().stream()
            .map(
                status -> new CreateAttendanceInput(lessonId, status.studentId(), status.present()))
            .toList();

    attendanceSpi.editAttendancesByLessonId(lessonId, attendanceInputList, jwtUser);

    return lessonRepository
        .findByIdAndOwnerId(lessonId, jwtUser.userId())
        .map(lesson -> lessonMapper.editLesson(lesson, input))
        .map(this::saveLesson)
        .map(lessonMapper::toDto);
  }

  @Transactional
  public Optional<LessonDto> softDeleteLesson(UUID lessonId, JwtUser jwtUser) {
    log.info("Soft deleting lesson: {}", lessonId);
    return lessonRepository
        .findByIdAndOwnerId(lessonId, jwtUser.userId())
        .map(
            lesson -> {
              lesson.setDeletedAt(OffsetDateTime.now());
              return saveLesson(lesson);
            })
        .map(lessonMapper::toDto);
  }

  @Transactional(readOnly = true)
  public List<LessonDto> getLessonsByGroupId(UUID groupId, JwtUser jwtUser) {
    log.info("Getting lessons by groupId={} for ownerId={}", groupId, jwtUser.userId());
    return lessonRepository.findAllByGroupIdAndOwnerId(groupId, jwtUser.userId()).stream()
        .map(lessonMapper::toDto)
        .toList();
  }

  @Transactional(readOnly = true)
  public Optional<LessonDto> getLastLessonByGroupId(UUID groupId, JwtUser jwtUser) {
    log.info("Getting last lesson by groupId={} for ownerId={}", groupId, jwtUser.userId());
    return lessonRepository.findLastLesson(groupId, jwtUser.userId());
  }

  private Lesson saveLesson(Lesson lesson) {
    log.info("Saving lesson: {}", lesson);
    return lessonRepository.saveAndFlush(lesson);
  }
}
