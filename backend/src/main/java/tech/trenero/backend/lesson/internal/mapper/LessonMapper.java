package tech.trenero.backend.lesson.internal.mapper;

import java.util.UUID;
import org.mapstruct.BeanMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.MappingTarget;
import org.mapstruct.Named;
import org.mapstruct.NullValuePropertyMappingStrategy;
import tech.trenero.backend.codegen.types.CreateLessonInput;
import tech.trenero.backend.codegen.types.Group;
import tech.trenero.backend.lesson.internal.entity.Lesson;

@Mapper(componentModel = ComponentModel.SPRING)
public interface LessonMapper {
  @Mapping(target = "group", source = "groupId", qualifiedByName = "groupFromId")
  tech.trenero.backend.codegen.types.Lesson toGraphql(Lesson lesson);

  @Named("groupFromId")
  default Group groupFromId(UUID groupId) {
    return Group.newBuilder().id(groupId).build();
  }

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Lesson toLesson(CreateLessonInput input, UUID ownerId);

  @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.SET_TO_NULL)
  Lesson editLesson(@MappingTarget Lesson lesson, CreateLessonInput input);
}
