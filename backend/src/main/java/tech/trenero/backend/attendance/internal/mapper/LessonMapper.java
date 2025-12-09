package tech.trenero.backend.attendance.internal.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants.ComponentModel;
import tech.trenero.backend.attendance.internal.entity.Lesson;
import tech.trenero.backend.attendance.internal.request.LessonRequest;

@Mapper(componentModel = ComponentModel.SPRING)
public interface LessonMapper {
  Lesson toLesson(LessonRequest lessonRequest);
}
