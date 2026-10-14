package org.trenero.backend.group.internal.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.trenero.backend.TestDays;
import org.trenero.backend.common.domain.VisitStatus;
import org.trenero.backend.common.domain.VisitType;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.group.external.response.GroupResponse;
import org.trenero.backend.group.external.response.GroupStudentResponse;
import org.trenero.backend.group.internal.domain.Group;
import org.trenero.backend.group.internal.mapper.GroupMapper;
import org.trenero.backend.group.internal.repository.GroupRepository;
import org.trenero.backend.group.internal.response.GroupReportResponse;
import org.trenero.backend.group.internal.response.GroupReportStudentResponse;
import org.trenero.backend.lesson.external.response.LessonResponse;
import org.trenero.backend.lesson.external.spi.LessonSpi;
import org.trenero.backend.student.external.response.StudentResponse;
import org.trenero.backend.student.external.spi.StudentSpi;
import org.trenero.backend.transaction.external.spi.TransactionSpi;
import org.trenero.backend.visit.external.response.VisitResponse;
import org.trenero.backend.visit.external.spi.VisitSpi;

/**
 * Tests for {@link GroupService#getGroupReport}, which feeds the attendance table of the group
 * page.
 *
 * <p>The rows of the report used to come from the students linked to the group, so a student that
 * came to a lesson and then left the group vanished from the table. The rows are now driven by the
 * visits of the reported lessons, so the students that left keep showing up, while the students
 * still linked to the group are listed with an empty result when the month holds no visit.
 */
class GroupServiceGetGroupReportTest {

  private static final OffsetDateTime CREATED_AT =
      OffsetDateTime.of(2026, 10, 8, 0, 0, 0, 0, ZoneOffset.UTC);

  private static final UUID GROUP_ID = UUID.randomUUID();
  private static final UUID LESSON_ID = UUID.randomUUID();
  private static final UUID CURRENT_STUDENT_ID = UUID.randomUUID();
  private static final UUID LEFT_STUDENT_ID = UUID.randomUUID();

  // The report reads the month widened by a day on both ends, so that a lesson of the first day of
  // the month that carries an offset ahead of UTC is not clipped by the range.
  private static final OffsetDateTime FEBRUARY_RANGE_START = TestDays.day(2026, 1, 31);
  private static final OffsetDateTime FEBRUARY_RANGE_END = TestDays.day(2026, 3, 1);

  private final JwtUser jwtUser = new JwtUser(UUID.randomUUID(), "owner@example.com");
  private final GroupRepository groupRepository = mock(GroupRepository.class);
  private final GroupMapper groupMapper = mock(GroupMapper.class);
  private final GroupStudentService groupStudentService = mock(GroupStudentService.class);
  private final LessonSpi lessonSpi = mock(LessonSpi.class);
  private final StudentSpi studentSpi = mock(StudentSpi.class);
  private final VisitSpi visitSpi = mock(VisitSpi.class);
  private final TransactionSpi transactionSpi = mock(TransactionSpi.class);

  private final Group group = mock(Group.class);

  @Test
  void listsTheStudentsOfTheLessonVisitsEvenAfterTheyLeftTheGroup() {
    when(groupRepository.findByIdAndOwnerId(GROUP_ID, jwtUser.id())).thenReturn(Optional.of(group));
    when(groupMapper.toResponse(group)).thenReturn(groupResponse());
    // Only the current student is still linked to the group.
    when(groupStudentService.getStudentsByGroupId(GROUP_ID, jwtUser))
        .thenReturn(List.of(groupStudentLink(CURRENT_STUDENT_ID)));
    when(lessonSpi.getLessonsByGroupIdAndDateRange(
            GROUP_ID, FEBRUARY_RANGE_START, FEBRUARY_RANGE_END, jwtUser))
        .thenReturn(List.of(lesson(LESSON_ID, TestDays.day(2026, 2, 5))));
    // The left student has a visit of the reported month.
    when(visitSpi.getVisitsByLessonIds(List.of(LESSON_ID), jwtUser))
        .thenReturn(List.of(visit(LESSON_ID, LEFT_STUDENT_ID, VisitStatus.PRESENT)));
    when(studentSpi.getStudentsByIds(List.of(CURRENT_STUDENT_ID, LEFT_STUDENT_ID), jwtUser))
        .thenReturn(
            Map.of(
                CURRENT_STUDENT_ID, student(CURRENT_STUDENT_ID, "Zoe Current"),
                LEFT_STUDENT_ID, student(LEFT_STUDENT_ID, "Anna Left")));
    when(transactionSpi.getTransactionsByStudentIds(
            List.of(CURRENT_STUDENT_ID, LEFT_STUDENT_ID), jwtUser))
        .thenReturn(Map.of());

    GroupReportResponse report = groupService().getGroupReport(GROUP_ID, 2026, 2, jwtUser);

    assertThat(report.getStudents())
        .extracting(GroupReportStudentResponse::getFullName)
        .containsExactly("Anna Left", "Zoe Current");

    GroupReportStudentResponse leftStudent = report.getStudents().getFirst();
    assertThat(leftStudent.getPresentDays())
        .as("the left student keeps their attendance mark")
        .containsExactly(5);
    assertThat(leftStudent.getPresentCount()).isEqualTo(1);
    assertThat(leftStudent.getLessonCount()).isEqualTo(1);

    GroupReportStudentResponse currentStudent = report.getStudents().get(1);
    assertThat(currentStudent.getPresentCount())
        .as("a student still in the group without a visit keeps an empty result")
        .isZero();

    assertThat(report.getTotalPresent()).isEqualTo(1);
    assertThat(report.getTotalLessons()).isEqualTo(2);

    verify(visitSpi).getVisitsByLessonIds(List.of(LESSON_ID), jwtUser);
    // The report is no longer read through the students, so a left student cannot be missed.
    verify(visitSpi, never()).getVisitsByStudentIds(any(), any());
  }

  @Test
  void buildsAnEmptyReportWhenTheGroupHasNeitherStudentsNorVisits() {
    when(groupRepository.findByIdAndOwnerId(GROUP_ID, jwtUser.id())).thenReturn(Optional.of(group));
    when(groupMapper.toResponse(group)).thenReturn(groupResponse());
    when(groupStudentService.getStudentsByGroupId(GROUP_ID, jwtUser)).thenReturn(List.of());
    when(lessonSpi.getLessonsByGroupIdAndDateRange(
            GROUP_ID, FEBRUARY_RANGE_START, FEBRUARY_RANGE_END, jwtUser))
        .thenReturn(List.of());

    GroupReportResponse report = groupService().getGroupReport(GROUP_ID, 2026, 2, jwtUser);

    assertThat(report.getStudents()).isEmpty();
    assertThat(report.getTotalPresent()).isZero();
    assertThat(report.getTotalLessons()).isZero();
    verify(visitSpi, never()).getVisitsByLessonIds(any(), any());
  }

  /** Only the group, its links, its lessons, the visits and the students are used by the report. */
  private GroupService groupService() {
    return new GroupService(
        groupRepository,
        groupMapper,
        new GroupReportService(),
        groupStudentService,
        lessonSpi,
        studentSpi,
        visitSpi,
        transactionSpi,
        null);
  }

  private static GroupResponse groupResponse() {
    return new GroupResponse(GROUP_ID, "Beginners", null, null, CREATED_AT);
  }

  private static GroupStudentResponse groupStudentLink(UUID studentId) {
    return new GroupStudentResponse(UUID.randomUUID(), GROUP_ID, studentId, null);
  }

  private static StudentResponse student(UUID studentId, String fullName) {
    return new StudentResponse(studentId, fullName, null, null, null, CREATED_AT, false);
  }

  private static LessonResponse lesson(UUID lessonId, OffsetDateTime date) {
    return new LessonResponse(lessonId, date, CREATED_AT, GROUP_ID);
  }

  private static VisitResponse visit(UUID lessonId, UUID studentId, VisitStatus status) {
    return new VisitResponse(
        UUID.randomUUID(), status, VisitType.REGULAR, lessonId, studentId, CREATED_AT);
  }
}
