package tech.trenero.backend.lesson.internal.mapper;

import java.util.UUID;
import org.mapstruct.BeanMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;
import tech.trenero.backend.common.dto.LessonDto;
import tech.trenero.backend.lesson.internal.entity.Lesson;
import tech.trenero.backend.lesson.internal.input.CreateLessonInput;

@Mapper(componentModel = ComponentModel.SPRING)
public interface LessonMapper {
  LessonDto toDto(Lesson lesson);

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Lesson toLesson(CreateLessonInput input, UUID ownerId);

  @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.SET_TO_NULL)
  Lesson editLesson(@MappingTarget Lesson lesson, CreateLessonInput input);
}
