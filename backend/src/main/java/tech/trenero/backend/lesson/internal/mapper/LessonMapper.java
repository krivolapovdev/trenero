package tech.trenero.backend.lesson.internal.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants.ComponentModel;
import tech.trenero.backend.common.dto.LessonDto;
import tech.trenero.backend.lesson.internal.entity.Lesson;

@Mapper(componentModel = ComponentModel.SPRING)
public interface LessonMapper {
  LessonDto toDto(Lesson lesson);
}
