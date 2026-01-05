package tech.trenero.backend.student.internal.validator;

import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.dto.StudentDto;
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
    Objects.requireNonNull(studentId, "studentId is required");
    Objects.requireNonNull(jwtUser, "jwtUser is required");

    studentService
        .getStudentById(studentId, jwtUser)
        .filter(student -> !student.deleted())
        .orElseThrow(() -> new EntityNotFoundException("Student not found by id: " + studentId));
  }

  @Override
  public void validateStudentIdsList(List<UUID> studentIds, JwtUser jwtUser)
      throws EntityNotFoundException {
    Objects.requireNonNull(studentIds, "studentIds is required");
    Objects.requireNonNull(jwtUser, "jwtUser is required");

    Set<UUID> availableStudentIds =
        studentService.getStudentListByIds(studentIds, jwtUser).stream()
            .map(StudentDto::id)
            .collect(Collectors.toSet());

    studentIds.forEach(
        studentId -> {
          if (!availableStudentIds.contains(studentId)) {
            throw new EntityNotFoundException("Student not found by id: " + studentId);
          }
        });
  }
}
