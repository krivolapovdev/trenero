package tech.trenero.backend.attendance.internal.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import tech.trenero.backend.attendance.internal.entity.Lesson;
import tech.trenero.backend.attendance.internal.mapper.LessonMapper;
import tech.trenero.backend.attendance.internal.repository.LessonRepository;
import tech.trenero.backend.attendance.internal.request.LessonRequest;

@Service
@RequiredArgsConstructor
@Slf4j
public class LessonService {
  private final LessonMapper lessonMapper;
  private final LessonRepository lessonRepository;

  public Lesson create(LessonRequest lessonRequest) {
    log.info("Creating lesson={}", lessonRequest);
    var lesson = lessonMapper.toLesson(lessonRequest);
    return save(lesson);
  }

  public Lesson save(Lesson lesson) {
    log.info("Saving lesson {}", lesson);
    return lessonRepository.save(lesson);
  }
}
