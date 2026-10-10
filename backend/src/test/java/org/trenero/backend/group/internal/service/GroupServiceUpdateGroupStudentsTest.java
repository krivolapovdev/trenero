package org.trenero.backend.group.internal.service;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.group.external.response.GroupResponse;
import org.trenero.backend.group.external.response.GroupStudentResponse;
import org.trenero.backend.group.internal.domain.Group;
import org.trenero.backend.group.internal.mapper.GroupMapper;
import org.trenero.backend.group.internal.repository.GroupRepository;

/**
 * Tests the student reconciliation of {@link GroupService#updateGroup}, which the group students
 * page drives: a student the request left out is dropped, a picked student the group did not hold
 * yet is added.
 */
class GroupServiceUpdateGroupStudentsTest {

  private static final UUID GROUP_ID = UUID.randomUUID();
  private static final UUID ANNA_ID = UUID.randomUUID();
  private static final UUID IVAN_ID = UUID.randomUUID();
  private static final UUID NEW_STUDENT_ID = UUID.randomUUID();

  private final JwtUser jwtUser = new JwtUser(UUID.randomUUID(), "owner@example.com");
  private final GroupRepository groupRepository = mock(GroupRepository.class);
  private final GroupMapper groupMapper = mock(GroupMapper.class);
  private final GroupStudentService groupStudentService = mock(GroupStudentService.class);
  private final GroupService self = mock(GroupService.class);

  private final Group group = mock(Group.class);

  @Test
  void addsThePickedStudentsAndDropsTheRest() {
    givenExistingStudents(ANNA_ID, IVAN_ID);

    groupService()
        .updateGroup(
            GROUP_ID,
            Map.of("studentIds", List.of(IVAN_ID.toString(), NEW_STUDENT_ID.toString())),
            jwtUser);

    verify(groupStudentService).removeStudentFromGroup(ANNA_ID, GROUP_ID, jwtUser);
    verify(groupStudentService).addStudentsToGroup(GROUP_ID, List.of(NEW_STUDENT_ID), jwtUser);
  }

  @Test
  void keepsTheStudentsThatStayPicked() {
    givenExistingStudents(ANNA_ID, IVAN_ID);

    groupService()
        .updateGroup(
            GROUP_ID,
            Map.of("studentIds", List.of(ANNA_ID.toString(), IVAN_ID.toString())),
            jwtUser);

    verify(groupStudentService, never()).removeStudentFromGroup(any(), any(), any());
    verify(groupStudentService, never()).addStudentsToGroup(any(), any(), any());
  }

  @Test
  void dropsEveryStudentWhenTheRequestPicksNone() {
    givenExistingStudents(ANNA_ID, IVAN_ID);

    groupService().updateGroup(GROUP_ID, Map.of("studentIds", List.of()), jwtUser);

    verify(groupStudentService).removeStudentFromGroup(ANNA_ID, GROUP_ID, jwtUser);
    verify(groupStudentService).removeStudentFromGroup(IVAN_ID, GROUP_ID, jwtUser);
    verify(groupStudentService, never()).addStudentsToGroup(any(), any(), any());
  }

  @Test
  void leavesTheStudentsUntouchedWhenTheRequestDoesNotPickAny() {
    givenExistingStudents(ANNA_ID, IVAN_ID);

    groupService().updateGroup(GROUP_ID, Map.of("name", "Group B"), jwtUser);

    verify(groupStudentService, never()).getStudentsByGroupId(any(), any());
    verify(groupStudentService, never()).removeStudentFromGroup(any(), any(), any());
    verify(groupStudentService, never()).addStudentsToGroup(any(), any(), any());
  }

  private void givenExistingStudents(UUID... studentIds) {
    when(groupRepository.findByIdAndOwnerId(GROUP_ID, jwtUser.id())).thenReturn(Optional.of(group));
    when(groupMapper.updateGroup(any(), any())).thenReturn(group);
    when(self.saveGroup(any())).thenReturn(group);
    when(groupMapper.toResponse(any()))
        .thenReturn(
            new GroupResponse(
                GROUP_ID,
                "Group A",
                null,
                null,
                OffsetDateTime.of(2026, 10, 8, 0, 0, 0, 0, ZoneOffset.UTC)));
    when(groupStudentService.getStudentsByGroupId(GROUP_ID, jwtUser))
        .thenReturn(
            Arrays.stream(studentIds)
                .map(
                    studentId ->
                        new GroupStudentResponse(UUID.randomUUID(), GROUP_ID, studentId, null))
                .toList());
  }

  /** Only the group and group student collaborators are used by the reconcile. */
  private GroupService groupService() {
    return new GroupService(
        groupRepository, groupMapper, null, groupStudentService, null, null, null, null, self);
  }
}
