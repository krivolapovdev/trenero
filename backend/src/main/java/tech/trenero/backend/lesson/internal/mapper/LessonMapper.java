package tech.trenero.backend.lesson.internal.mapper;

import graphql.schema.DataFetchingEnvironment;
import java.util.Map;
import java.util.UUID;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.Named;
import org.mapstruct.ReportingPolicy;
import tech.trenero.backend.codegen.types.CreateLessonInput;
import tech.trenero.backend.codegen.types.Group;
import tech.trenero.backend.codegen.types.UpdateLessonInput;
import tech.trenero.backend.lesson.internal.entity.Lesson;

@Mapper(componentModel = ComponentModel.SPRING, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface LessonMapper {
  @Mapping(target = "group", source = "groupId", qualifiedByName = "groupFromId")
  tech.trenero.backend.codegen.types.Lesson toGraphql(Lesson lesson);

  @Named("groupFromId")
  default Group groupFromId(UUID groupId) {
    return Group.newBuilder().id(groupId).build();
  }

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Lesson toLesson(CreateLessonInput input, UUID ownerId);

  default Lesson updateLesson(
      Lesson lesson, UpdateLessonInput input, DataFetchingEnvironment environment) {
    if (lesson == null || input == null || environment == null) {
      return lesson;
    }

    Map<String, Object> inputMap = environment.getArgument("input");
    if (inputMap == null) {
      return lesson;
    }

    Map<String, Runnable> updates =
        Map.of(
            "groupId", () -> lesson.setGroupId(input.getGroupId()),
            "startDateTime", () -> lesson.setStartDateTime(input.getStartDateTime()));

    updates.entrySet().stream()
        .filter(entry -> inputMap.containsKey(entry.getKey()))
        .forEach(entry -> entry.getValue().run());

    return lesson;
  }
}
