package tech.trenero.backend.student.internal.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants.ComponentModel;
import tech.trenero.backend.common.dto.StudentDto;
import tech.trenero.backend.student.internal.entity.Student;

@Mapper(componentModel = ComponentModel.SPRING)
public interface StudentMapper {
  StudentDto toStudentDto(Student student);
}
