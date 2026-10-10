package org.trenero.backend.group.internal.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.trenero.backend.common.domain.StudentStatus;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.group.external.response.GroupResponse;
import org.trenero.backend.group.external.response.GroupStudentResponse;
import org.trenero.backend.group.internal.domain.Group;
import org.trenero.backend.group.internal.mapper.GroupMapper;
import org.trenero.backend.group.internal.repository.GroupRepository;
import org.trenero.backend.group.internal.response.GroupStudentSummaryResponse;
import org.trenero.backend.student.external.response.StudentResponse;
import org.trenero.backend.student.external.response.StudentWithStatusesResponse;
import org.trenero.backend.student.external.spi.StudentSpi;

/**
 * Tests for {@link GroupService#getGroupStudents}, which feeds the student list of the group page.
 *
 * <p>The badges used to be read from the last lesson of any kind, so the group page showed whether
 * a student came to the last lesson of any group instead of the last lesson of the shown group. The
 * statuses are now asked from {@link StudentSpi#getStudentsWithStatusesByGroupId}.
 */
class GroupServiceGetGroupStudentsTest {

  private static final OffsetDateTime CREATED_AT =
      OffsetDateTime.of(2026, 10, 8, 0, 0, 0, 0, ZoneOffset.UTC);

  private static final UUID GROUP_ID = UUID.randomUUID();
  private static final UUID STUDENT_ID = UUID.randomUUID();

  private final JwtUser jwtUser = new JwtUser(UUID.randomUUID(), "owner@example.com");
  private final GroupRepository groupRepository = mock(GroupRepository.class);
  private final GroupMapper groupMapper = mock(GroupMapper.class);
  private final GroupStudentService groupStudentService = mock(GroupStudentService.class);
  private final StudentSpi studentSpi = mock(StudentSpi.class);

  private final Group group = mock(Group.class);

  @Test
  void readsTheStudentBadgesScopedToTheGroup() {
    when(groupRepository.findByIdAndOwnerId(GROUP_ID, jwtUser.id())).thenReturn(Optional.of(group));
    when(groupMapper.toResponse(group)).thenReturn(groupResponse());
    when(groupStudentService.getStudentsByGroupId(GROUP_ID, jwtUser))
        .thenReturn(
            List.of(new GroupStudentResponse(UUID.randomUUID(), GROUP_ID, STUDENT_ID, null)));
    when(studentSpi.getStudentsWithStatusesByGroupId(List.of(STUDENT_ID), GROUP_ID, jwtUser))
        .thenReturn(
            Map.of(
                STUDENT_ID,
                new StudentWithStatusesResponse(studentResponse(), Set.of(StudentStatus.MISSING))));

    List<GroupStudentSummaryResponse> students = groupService().getGroupStudents(GROUP_ID, jwtUser);

    assertThat(students).hasSize(1);
    assertThat(students.getFirst().getStatuses()).containsExactly(StudentStatus.MISSING);
    verify(studentSpi).getStudentsWithStatusesByGroupId(List.of(STUDENT_ID), GROUP_ID, jwtUser);
  }

  /** Only the group, the group links and the student statuses are used by getGroupStudents. */
  private GroupService groupService() {
    return new GroupService(
        groupRepository,
        groupMapper,
        null,
        groupStudentService,
        null,
        studentSpi,
        null,
        null,
        null);
  }

  private static GroupResponse groupResponse() {
    return new GroupResponse(GROUP_ID, "Group A", null, null, CREATED_AT);
  }

  private static StudentResponse studentResponse() {
    return new StudentResponse(STUDENT_ID, "Ivan Petrov", null, null, null, CREATED_AT, false);
  }
}
