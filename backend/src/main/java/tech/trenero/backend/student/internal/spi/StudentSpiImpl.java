package tech.trenero.backend.student.internal.spi;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.dto.StudentDto;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.student.external.StudentSpi;
import tech.trenero.backend.student.internal.service.StudentService;

@Component
@RequiredArgsConstructor
public class StudentSpiImpl implements StudentSpi {
  private final StudentService studentService;

  @Override
  public List<StudentDto> getStudentsByGroupId(UUID groupId, JwtUser jwtUser) {
    if (groupId == null || jwtUser == null) {
      return List.of();
    }

    return studentService.getStudentsByGroupId(groupId, jwtUser);
  }

  @Override
  public Optional<StudentDto> getStudentById(UUID studentId, JwtUser jwtUser) {
    if (studentId == null || jwtUser == null) {
      return Optional.empty();
    }

    return studentService.getStudentById(studentId, jwtUser);
  }

  @Override
  public void assignGroupToStudents(UUID groupId, List<UUID> studentIds, JwtUser jwtUser) {
    if (groupId == null || studentIds == null || studentIds.isEmpty() || jwtUser == null) {
      return;
    }

    studentService.assignGroupToStudents(groupId, studentIds, jwtUser);
  }

  @Override
  public void updateStudentsGroup(UUID groupId, List<UUID> studentIds, JwtUser jwtUser) {
    if (groupId == null || studentIds == null || jwtUser == null) {
      return;
    }

    List<UUID> currentStudentIds =
        studentService.getStudentsByGroupId(groupId, jwtUser).stream().map(StudentDto::id).toList();

    List<UUID> toRemove =
        currentStudentIds.stream().filter(id -> !studentIds.contains(id)).toList();

    List<UUID> toAdd = studentIds.stream().filter(id -> !currentStudentIds.contains(id)).toList();

    if (!toRemove.isEmpty()) {
      studentService.assignGroupToStudents(null, toRemove, jwtUser);
    }

    if (!toAdd.isEmpty()) {
      studentService.assignGroupToStudents(groupId, toAdd, jwtUser);
    }
  }
}
