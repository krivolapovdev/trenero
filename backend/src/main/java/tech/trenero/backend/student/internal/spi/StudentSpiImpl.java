package tech.trenero.backend.student.internal.spi;

import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import tech.trenero.backend.codegen.types.Student;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.student.external.StudentSpi;
import tech.trenero.backend.student.internal.service.StudentService;

@Component
@RequiredArgsConstructor
public class StudentSpiImpl implements StudentSpi {
  private static final String STUDENT_IDS_MUST_NOT_BE_NULL = "studentIds must not be null";
  private static final String GROUP_ID_MUST_NOT_BE_NULL = "groupId must not be null";
  private static final String JWT_USER_MUST_NOT_BE_NULL = "jwtUser must not be null";
  private final StudentService studentService;

  @Override
  public List<Student> getStudentsByGroupId(UUID groupId, JwtUser jwtUser) {
    Objects.requireNonNull(groupId, GROUP_ID_MUST_NOT_BE_NULL);
    Objects.requireNonNull(jwtUser, JWT_USER_MUST_NOT_BE_NULL);

    return studentService.getStudentsByGroupId(groupId, jwtUser);
  }

  @Override
  public Optional<Student> findStudentById(UUID studentId, JwtUser jwtUser) {
    Objects.requireNonNull(studentId, STUDENT_IDS_MUST_NOT_BE_NULL);
    Objects.requireNonNull(jwtUser, JWT_USER_MUST_NOT_BE_NULL);

    return studentService.findStudentById(studentId, jwtUser);
  }

  @Override
  public Student getStudentById(UUID studentId, JwtUser jwtUser) throws EntityNotFoundException {
    return findStudentById(studentId, jwtUser)
        .orElseThrow(
            () ->
                new EntityNotFoundException(
                    "Student not found: studentId=%s".formatted(studentId)));
  }

  @Override
  public List<Student> getStudentsByIds(List<UUID> studentIds, JwtUser jwtUser)
      throws EntityNotFoundException {
    Objects.requireNonNull(studentIds, STUDENT_IDS_MUST_NOT_BE_NULL);
    Objects.requireNonNull(jwtUser, JWT_USER_MUST_NOT_BE_NULL);

    if (studentIds.isEmpty()) {
      return List.of();
    }

    List<Student> existingStudents = studentService.getStudentListByIds(studentIds, jwtUser);

    if (studentIds.size() != existingStudents.size()) {
      Set<UUID> existingIds =
          existingStudents.stream().map(Student::getId).collect(Collectors.toSet());

      List<UUID> missingIds = studentIds.stream().filter(id -> !existingIds.contains(id)).toList();

      throw new EntityNotFoundException("Students not found with IDs: " + missingIds);
    }

    return existingStudents;
  }

  @Override
  public void assignGroupToStudents(UUID groupId, List<UUID> studentIds, JwtUser jwtUser) {
    Objects.requireNonNull(groupId, GROUP_ID_MUST_NOT_BE_NULL);
    Objects.requireNonNull(studentIds, STUDENT_IDS_MUST_NOT_BE_NULL);
    Objects.requireNonNull(jwtUser, JWT_USER_MUST_NOT_BE_NULL);

    studentService.assignGroupToStudents(groupId, studentIds, jwtUser);
  }

  @Override
  public void editStudentsGroup(UUID groupId, List<UUID> studentIds, JwtUser jwtUser) {
    Objects.requireNonNull(groupId, GROUP_ID_MUST_NOT_BE_NULL);
    Objects.requireNonNull(studentIds, STUDENT_IDS_MUST_NOT_BE_NULL);
    Objects.requireNonNull(jwtUser, JWT_USER_MUST_NOT_BE_NULL);

    List<UUID> currentStudentIds =
        studentService.getStudentsByGroupId(groupId, jwtUser).stream().map(Student::getId).toList();

    List<UUID> toRemove =
        currentStudentIds.stream().filter(id -> !studentIds.contains(id)).toList();

    List<UUID> toAdd = studentIds.stream().filter(id -> !currentStudentIds.contains(id)).toList();

    if (!toRemove.isEmpty()) {
      studentService.removeGroupFromStudents(toRemove, jwtUser);
    }

    if (!toAdd.isEmpty()) {
      studentService.assignGroupToStudents(groupId, toAdd, jwtUser);
    }
  }

  @Override
  public void removeGroupFromStudents(UUID groupId, JwtUser jwtUser) {
    Objects.requireNonNull(groupId, GROUP_ID_MUST_NOT_BE_NULL);
    Objects.requireNonNull(jwtUser, JWT_USER_MUST_NOT_BE_NULL);

    List<UUID> studentIds =
        getStudentsByGroupId(groupId, jwtUser).stream().map(Student::getId).toList();

    if (!studentIds.isEmpty()) {
      studentService.assignGroupToStudents(null, studentIds, jwtUser);
    }
  }
}
