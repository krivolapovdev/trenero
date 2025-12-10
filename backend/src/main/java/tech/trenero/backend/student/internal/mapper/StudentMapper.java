package tech.trenero.backend.student.internal.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants.ComponentModel;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.student.internal.entity.Student;
import tech.trenero.backend.student.internal.request.CreateStudentRequest;

@Mapper(componentModel = ComponentModel.SPRING)
public interface StudentMapper {
  Student toStudent(CreateStudentRequest createStudentRequest);

  StudentResponse toStudentResponse(Student student);
}
