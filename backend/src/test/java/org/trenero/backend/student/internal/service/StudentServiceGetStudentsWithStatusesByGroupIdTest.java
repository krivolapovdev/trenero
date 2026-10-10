package org.trenero.backend.student.internal.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.Executor;
import org.junit.jupiter.api.Test;
import org.trenero.backend.common.domain.StudentStatus;
import org.trenero.backend.common.domain.VisitStatus;
import org.trenero.backend.common.domain.VisitType;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.lesson.external.response.LessonResponse;
import org.trenero.backend.lesson.external.spi.LessonSpi;
import org.trenero.backend.student.external.response.StudentResponse;
import org.trenero.backend.student.external.response.StudentWithStatusesResponse;
import org.trenero.backend.student.internal.domain.Student;
import org.trenero.backend.student.internal.mapper.StudentMapper;
import org.trenero.backend.student.internal.repository.StudentRepository;
import org.trenero.backend.transaction.external.spi.TransactionSpi;
import org.trenero.backend.visit.external.response.VisitResponse;
import org.trenero.backend.visit.external.spi.VisitSpi;

/**
 * Tests for {@link StudentService#getStudentsWithStatusesByGroupId} and {@link
 * StudentService#getStudentsWithStatusesByIds}.
 *
 * <p>The visit badge of the students on a group page used to be read from the last lesson of any
 * kind, so a student present at a lesson of another group showed "present" on every group. The
 * group-scoped badge reads the visit badge from the lessons of the group, while the payment badge
 * still sees every lesson.
 */
class StudentServiceGetStudentsWithStatusesByGroupIdTest {

  private static final OffsetDateTime CREATED_AT =
      OffsetDateTime.of(2026, 10, 8, 12, 0, 0, 0, ZoneOffset.UTC);

  private static final UUID STUDENT_ID = UUID.randomUUID();
  private static final UUID GROUP_ID = UUID.randomUUID();
  private static final UUID OTHER_GROUP_ID = UUID.randomUUID();
  private static final UUID GROUP_LESSON_ID = UUID.randomUUID();
  private static final UUID OTHER_GROUP_LESSON_ID = UUID.randomUUID();

  private final JwtUser jwtUser = new JwtUser(UUID.randomUUID(), "owner@example.com");
  private final StudentRepository studentRepository = mock(StudentRepository.class);
  private final StudentMapper studentMapper = mock(StudentMapper.class);
  private final TransactionSpi transactionSpi = mock(TransactionSpi.class);
  private final VisitSpi visitSpi = mock(VisitSpi.class);
  private final LessonSpi lessonSpi = mock(LessonSpi.class);

  @Test
  void readsTheVisitBadgeFromTheLessonOfTheGivenGroup() {
    givenAStudentAbsentAtTheGroupLessonAndPresentAtTheOtherOne();

    StudentWithStatusesResponse response =
        studentService()
            .getStudentsWithStatusesByGroupId(List.of(STUDENT_ID), GROUP_ID, jwtUser)
            .get(STUDENT_ID);

    assertThat(response.getStatuses())
        .contains(StudentStatus.MISSING)
        .doesNotContain(StudentStatus.PRESENT);
  }

  @Test
  void readsTheVisitBadgeFromEveryGroupWhenNoGroupIsGiven() {
    givenAStudentAbsentAtTheGroupLessonAndPresentAtTheOtherOne();

    StudentWithStatusesResponse response =
        studentService().getStudentsWithStatusesByIds(List.of(STUDENT_ID), jwtUser).get(STUDENT_ID);

    assertThat(response.getStatuses())
        .contains(StudentStatus.PRESENT)
        .doesNotContain(StudentStatus.MISSING);
  }

  private void givenAStudentAbsentAtTheGroupLessonAndPresentAtTheOtherOne() {
    Student student = mock(Student.class);

    when(studentRepository.findAllByIdsAndOwnerId(List.of(STUDENT_ID), jwtUser.id()))
        .thenReturn(List.of(student));
    when(studentMapper.toResponse(student))
        .thenReturn(
            new StudentResponse(STUDENT_ID, "Ivan Petrov", null, null, null, CREATED_AT, false));
    when(visitSpi.getVisitsByStudentIds(List.of(STUDENT_ID), jwtUser))
        .thenReturn(
            Map.of(
                STUDENT_ID,
                List.of(
                    visit(GROUP_LESSON_ID, VisitStatus.ABSENT),
                    visit(OTHER_GROUP_LESSON_ID, VisitStatus.PRESENT))));
    when(transactionSpi.getTransactionsByStudentIds(List.of(STUDENT_ID), jwtUser))
        .thenReturn(Map.of());
    when(lessonSpi.getLessonsByIds(List.of(GROUP_LESSON_ID, OTHER_GROUP_LESSON_ID), jwtUser))
        .thenReturn(
            Map.of(
                GROUP_LESSON_ID, lesson(GROUP_LESSON_ID, GROUP_ID, LocalDate.of(2026, 9, 1)),
                OTHER_GROUP_LESSON_ID,
                    lesson(OTHER_GROUP_LESSON_ID, OTHER_GROUP_ID, LocalDate.of(2026, 10, 8))));
  }

  /**
   * Only the students, the visits, the lessons and the payments are read, so the group
   * collaborators are left out and the shared pool is replaced by a direct executor.
   */
  private StudentService studentService() {
    Executor executor = Runnable::run;

    return new StudentService(
        studentRepository,
        studentMapper,
        null,
        new StudentStatusService(),
        null,
        null,
        transactionSpi,
        visitSpi,
        lessonSpi,
        executor);
  }

  private static VisitResponse visit(UUID lessonId, VisitStatus status) {
    return new VisitResponse(
        UUID.randomUUID(), status, VisitType.REGULAR, lessonId, STUDENT_ID, CREATED_AT);
  }

  private static LessonResponse lesson(UUID lessonId, UUID groupId, LocalDate date) {
    return new LessonResponse(lessonId, date, CREATED_AT, groupId);
  }
}
