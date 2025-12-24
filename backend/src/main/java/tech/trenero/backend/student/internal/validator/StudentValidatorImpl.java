package tech.trenero.backend.student.internal.validator;

import jakarta.persistence.EntityNotFoundException;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.student.external.StudentValidator;
import tech.trenero.backend.student.internal.service.StudentService;

@Component
@RequiredArgsConstructor
public class StudentValidatorImpl implements StudentValidator {
  private final StudentService studentService;

  @Override
  public void validateStudentIsPresentAndActive(UUID studentId, JwtUser jwtUser)
      throws EntityNotFoundException {
    studentService
        .getStudentById(studentId, jwtUser)
        .filter(student -> !student.isDeleted())
        .orElseThrow(() -> new EntityNotFoundException("Student not found by id: " + studentId));
  }
}
