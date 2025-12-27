package tech.trenero.backend.student.internal.mapper;

import java.util.UUID;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import tech.trenero.backend.common.dto.StudentDto;
import tech.trenero.backend.student.internal.entity.Student;
import tech.trenero.backend.student.internal.input.CreateStudentInput;

@Mapper(componentModel = ComponentModel.SPRING)
public interface StudentMapper {
  StudentDto toStudentDto(Student student);

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Student toStudent(CreateStudentInput input, UUID ownerId);
}
