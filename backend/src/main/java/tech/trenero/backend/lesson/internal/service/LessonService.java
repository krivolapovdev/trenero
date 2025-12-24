package tech.trenero.backend.lesson.internal.service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupValidator;
import tech.trenero.backend.lesson.internal.entity.Lesson;
import tech.trenero.backend.lesson.internal.input.CreateLessonInput;
import tech.trenero.backend.lesson.internal.repository.LessonRepository;

@Service
@Slf4j
@RequiredArgsConstructor
public class LessonService {
  private final LessonRepository lessonRepository;
  private final GroupValidator groupValidator;

  @Transactional(readOnly = true)
  public List<Lesson> getAllLessons(JwtUser jwtUser) {
    log.info("Getting all lessons for ownerId={}", jwtUser.userId());
    return lessonRepository.findAllByOwnerId(jwtUser.userId()).stream().toList();
  }

  @Transactional(readOnly = true)
  public Optional<Lesson> getLessonById(UUID lessonId, JwtUser jwtUser) {
    log.info("Getting lesson by id={} for ownerId={}", lessonId, jwtUser.userId());
    return lessonRepository.findByIdAndOwnerId(lessonId, jwtUser.userId());
  }

  @Transactional
  public Lesson createLesson(CreateLessonInput input, JwtUser jwtUser) {
    log.info(
        "Creating lesson for groupId='{}', startDateTime={}, ownerId={}",
        input.groupId(),
        input.startDateTime(),
        jwtUser.userId());

    groupValidator.validateGroupIsPresentAndActive(input.groupId(), jwtUser);

    Lesson lesson =
        Lesson.builder()
            .groupId(input.groupId())
            .startDateTime(input.startDateTime())
            .ownerId(jwtUser.userId())
            .deleted(false)
            .build();

    return saveLesson(lesson);
  }

  @Transactional
  public Optional<Lesson> softDeleteLesson(UUID lessonId, JwtUser jwtUser) {
    log.info("Soft deleting lesson: {}", lessonId);
    return lessonRepository
        .findByIdAndOwnerId(lessonId, jwtUser.userId())
        .map(
            lesson -> {
              lesson.setDeleted(true);
              return saveLesson(lesson);
            });
  }

  private Lesson saveLesson(Lesson lesson) {
    log.info("Saving lesson: {}", lesson);
    return lessonRepository.save(lesson);
  }
}
