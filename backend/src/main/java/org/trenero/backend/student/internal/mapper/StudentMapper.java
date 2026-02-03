package org.trenero.backend.student.internal.mapper;

import java.time.LocalDate;
import java.util.Map;
import java.util.UUID;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants.ComponentModel;
import org.mapstruct.ReportingPolicy;
import org.trenero.backend.common.response.StudentResponse;
import org.trenero.backend.student.internal.domain.Student;
import org.trenero.backend.student.internal.request.CreateStudentRequest;

@Mapper(componentModel = ComponentModel.SPRING, unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface StudentMapper {
  StudentResponse toResponse(Student student);

  @Mapping(target = "ownerId", expression = "java(ownerId)")
  Student toStudent(CreateStudentRequest request, UUID ownerId);

  default Student updateStudent(Student student, Map<String, Object> updates) {
    if (student == null || updates == null) {
      return student;
    }

    if (updates.containsKey("fullName")) {
      student.setFullName((String) updates.get("fullName"));
    }

    if (updates.containsKey("phone")) {
      student.setPhone((String) updates.get("phone"));
    }

    if (updates.containsKey("note")) {
      student.setNote((String) updates.get("note"));
    }

    if (updates.containsKey("birthdate")) {
      Object date = updates.get("birthdate");
      student.setBirthdate(date != null ? LocalDate.parse(date.toString()) : null);
    }

    return student;
  }
}
