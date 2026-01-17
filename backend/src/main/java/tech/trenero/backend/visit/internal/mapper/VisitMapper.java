package tech.trenero.backend.visit.internal.mapper;

import static tech.trenero.backend.codegen.DgsConstants.UPDATEVISITINPUT.Present;

import graphql.schema.DataFetchingEnvironment;
import java.util.Map;
import java.util.UUID;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.Named;
import org.mapstruct.ReportingPolicy;
import tech.trenero.backend.codegen.types.CreateVisitInput;
import tech.trenero.backend.codegen.types.Lesson;
import tech.trenero.backend.codegen.types.Student;
import tech.trenero.backend.codegen.types.UpdateVisitInput;
import tech.trenero.backend.visit.internal.entity.Visit;

@Mapper(componentModel = ComponentModel.SPRING, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface VisitMapper {
  @Mapping(target = "lesson", source = "lessonId", qualifiedByName = "lessonFromId")
  @Mapping(target = "student", source = "studentId", qualifiedByName = "studentFromId")
  tech.trenero.backend.codegen.types.Visit toGraphql(Visit visit);

  @Named("lessonFromId")
  default Lesson lessonFromId(UUID lessonId) {
    return Lesson.newBuilder().id(lessonId).build();
  }

  @Named("studentFromId")
  default Student studentFromId(UUID studentId) {
    return Student.newBuilder().id(studentId).build();
  }

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Visit toVisit(CreateVisitInput input, UUID ownerId);

  default Visit updateVisit(
      Visit visit, UpdateVisitInput input, DataFetchingEnvironment environment) {
    if (visit == null || input == null || environment == null) {
      return visit;
    }

    Map<String, Object> inputMap = environment.getArgument("input");
    if (inputMap == null) {
      return visit;
    }

    Map<String, Runnable> updates = Map.of(Present, () -> visit.setPresent(input.getPresent()));

    updates.entrySet().stream()
        .filter(entry -> inputMap.containsKey(entry.getKey()))
        .forEach(entry -> entry.getValue().run());

    return visit;
  }
}
