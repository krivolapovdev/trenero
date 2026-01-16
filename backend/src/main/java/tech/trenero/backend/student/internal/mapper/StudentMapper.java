package tech.trenero.backend.student.internal.mapper;

import java.util.UUID;
import org.mapstruct.BeanMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.MappingTarget;
import org.mapstruct.Named;
import org.mapstruct.NullValuePropertyMappingStrategy;
import tech.trenero.backend.codegen.types.CreateStudentInput;
import tech.trenero.backend.codegen.types.Group;
import tech.trenero.backend.student.internal.entity.Student;

@Mapper(componentModel = ComponentModel.SPRING)
public interface StudentMapper {
  @Mapping(target = "group", source = "groupId", qualifiedByName = "groupFromId")
  tech.trenero.backend.codegen.types.Student toGraphql(Student student);

  @Named("groupFromId")
  default Group groupFromId(UUID groupId) {
    return Group.newBuilder().id(groupId).build();
  }

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Student toStudent(CreateStudentInput input, UUID ownerId);

  @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.SET_TO_NULL)
  Student editStudent(@MappingTarget Student student, CreateStudentInput input);
}
