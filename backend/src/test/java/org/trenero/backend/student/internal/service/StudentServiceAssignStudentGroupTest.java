package org.trenero.backend.student.internal.service;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.group.external.response.GroupStudentResponse;
import org.trenero.backend.group.external.spi.GroupStudentSpi;
import org.trenero.backend.student.external.response.StudentResponse;
import org.trenero.backend.student.internal.domain.Student;
import org.trenero.backend.student.internal.mapper.StudentMapper;
import org.trenero.backend.student.internal.repository.StudentRepository;

/**
 * Tests for the group reassignment of {@link StudentService#updateStudent}, which the student group
 * sheet drives: the previous link is dropped and the new one carries the day the user picked.
 */
class StudentServiceAssignStudentGroupTest {

  private static final UUID STUDENT_ID = UUID.randomUUID();
  private static final UUID OLD_GROUP_ID = UUID.randomUUID();
  private static final UUID NEW_GROUP_ID = UUID.randomUUID();

  private final JwtUser jwtUser = new JwtUser(UUID.randomUUID(), "owner@example.com");
  private final StudentRepository studentRepository = mock(StudentRepository.class);
  private final StudentMapper studentMapper = mock(StudentMapper.class);
  private final StudentService self = mock(StudentService.class);
  private final GroupStudentSpi groupStudentSpi = mock(GroupStudentSpi.class);

  private final Student student = mock(Student.class);

  @Test
  void forwardsThePickedJoinedAtToTheGroupModule() {
    givenExistingGroup();

    studentService()
        .updateStudent(
            STUDENT_ID,
            Map.of("groupId", NEW_GROUP_ID.toString(), "joinedAt", "2026-10-09"),
            jwtUser);

    verify(groupStudentSpi).removeStudentFromGroup(STUDENT_ID, OLD_GROUP_ID, jwtUser);
    verify(groupStudentSpi)
        .addStudentToGroup(STUDENT_ID, NEW_GROUP_ID, LocalDate.of(2026, 10, 9), jwtUser);
  }

  @Test
  void forwardsNoJoinedAtWhenTheSheetSentNone() {
    givenExistingGroup();

    studentService().updateStudent(STUDENT_ID, Map.of("groupId", NEW_GROUP_ID.toString()), jwtUser);

    verify(groupStudentSpi)
        .addStudentToGroup(eq(STUDENT_ID), eq(NEW_GROUP_ID), isNull(), eq(jwtUser));
  }

  private void givenExistingGroup() {
    when(studentRepository.findByIdAndOwnerId(STUDENT_ID, jwtUser.id()))
        .thenReturn(Optional.of(student));
    when(groupStudentSpi.getGroupsByStudentId(STUDENT_ID, jwtUser))
        .thenReturn(
            List.of(new GroupStudentResponse(UUID.randomUUID(), OLD_GROUP_ID, STUDENT_ID, null)));
    when(studentMapper.updateStudent(any(), any())).thenReturn(student);
    when(self.saveStudent(any())).thenReturn(student);
    when(studentMapper.toResponse(any()))
        .thenReturn(
            new StudentResponse(
                STUDENT_ID,
                "Ivan Petrov",
                null,
                null,
                null,
                OffsetDateTime.of(2026, 10, 8, 0, 0, 0, 0, ZoneOffset.UTC)));
  }

  /** Only the group link collaborators are used by {@link StudentService#updateStudent}. */
  private StudentService studentService() {
    return new StudentService(
        studentRepository,
        studentMapper,
        self,
        null,
        null,
        groupStudentSpi,
        null,
        null,
        null,
        null);
  }
}
