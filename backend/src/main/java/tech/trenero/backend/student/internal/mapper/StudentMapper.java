package tech.trenero.backend.student.internal.mapper;

import java.util.UUID;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.ReportingPolicy;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.student.internal.model.Student;
import tech.trenero.backend.student.internal.request.CreateStudentRequest;
import tech.trenero.backend.student.internal.request.UpdateStudentRequest;

@Mapper(componentModel = ComponentModel.SPRING, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface StudentMapper {
  StudentResponse toResponse(Student student);

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Student toStudent(CreateStudentRequest request, UUID ownerId);

  default Student updateStudent(Student student, UpdateStudentRequest request) {
    if (student == null || request == null) {
      return student;
    }

    request.fullName().ifPresent(student::setFullName);
    request.birthdate().ifPresent(student::setBirthdate);
    request.phone().ifPresent(student::setPhone);
    request.note().ifPresent(student::setNote);
    request.groupId().ifPresent(student::setGroupId);

    return student;
  }
}
