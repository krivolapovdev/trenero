package org.trenero.backend.lesson.internal.mapper;

import java.util.UUID;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.ReportingPolicy;
import org.trenero.backend.common.response.LessonResponse;
import org.trenero.backend.lesson.internal.domain.Lesson;
import org.trenero.backend.lesson.internal.request.CreateLessonRequest;
import org.trenero.backend.lesson.internal.request.UpdateLessonRequest;

@Mapper(componentModel = ComponentModel.SPRING, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface LessonMapper {
  LessonResponse toResponse(Lesson lesson);

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Lesson toLesson(CreateLessonRequest request, UUID ownerId);

  default Lesson updateLesson(Lesson lesson, UpdateLessonRequest request) {
    if (lesson == null || request == null) {
      return lesson;
    }

    if (request.date() != null) {
      lesson.setDate(request.date());
    }

    return lesson;
  }
}
