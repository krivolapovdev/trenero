package tech.trenero.backend.student.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants.ComponentModel;
import tech.trenero.backend.student.entity.Student;
import tech.trenero.backend.student.request.StudentRequest;
import tech.trenero.backend.student.response.StudentResponse;

@Mapper(componentModel = ComponentModel.SPRING)
public interface StudentMapper {
  Student toStudent(StudentRequest studentRequest);

  StudentResponse toStudentResponse(Student student);
}
