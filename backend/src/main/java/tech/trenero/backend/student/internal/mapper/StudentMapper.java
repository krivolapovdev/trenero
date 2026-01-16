package tech.trenero.backend.student.internal.mapper;

import graphql.schema.DataFetchingEnvironment;
import java.util.Map;
import java.util.UUID;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.Named;
import org.mapstruct.ReportingPolicy;
import tech.trenero.backend.codegen.types.CreateStudentInput;
import tech.trenero.backend.codegen.types.Group;
import tech.trenero.backend.codegen.types.UpdateStudentInput;
import tech.trenero.backend.student.internal.entity.Student;

@Mapper(componentModel = ComponentModel.SPRING, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface StudentMapper {
  @Mapping(target = "group", source = "groupId", qualifiedByName = "groupFromId")
  tech.trenero.backend.codegen.types.Student toGraphql(Student student);

  @Named("groupFromId")
  default Group groupFromId(UUID groupId) {
    return Group.newBuilder().id(groupId).build();
  }

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Student toStudent(CreateStudentInput input, UUID ownerId);

  default Student updateStudent(
      Student student, UpdateStudentInput input, DataFetchingEnvironment environment) {
    if (student == null || input == null || environment == null) {
      return student;
    }

    Map<String, Object> inputMap = environment.getArgument("input");

    if (inputMap == null) {
      return student;
    }

    Map<String, Runnable> updates =
        Map.of(
            "fullName", () -> student.setFullName(input.getFullName()),
            "birthdate", () -> student.setBirthdate(input.getBirthdate()),
            "phone", () -> student.setPhone(input.getPhone()),
            "note", () -> student.setNote(input.getNote()),
            "groupId", () -> student.setGroupId(input.getGroupId()));

    updates.entrySet().stream()
        .filter(entry -> inputMap.containsKey(entry.getKey()))
        .forEach(entry -> entry.getValue().run());

    return student;
  }
}
