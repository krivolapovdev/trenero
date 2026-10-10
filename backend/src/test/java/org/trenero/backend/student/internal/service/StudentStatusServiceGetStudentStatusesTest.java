package org.trenero.backend.student.internal.service;

import static org.assertj.core.api.Assertions.assertThat;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.trenero.backend.common.domain.StudentStatus;
import org.trenero.backend.common.domain.TransactionType;
import org.trenero.backend.common.domain.VisitStatus;
import org.trenero.backend.common.domain.VisitType;
import org.trenero.backend.lesson.external.response.LessonResponse;
import org.trenero.backend.transaction.external.response.StudentPaymentDetailsResponse;
import org.trenero.backend.transaction.external.response.TransactionResponse;
import org.trenero.backend.visit.external.response.VisitResponse;

/**
 * Tests for {@link StudentStatusService#getStudentStatuses}.
 *
 * <p>The visit badge used to be read from the last group lesson only, so an individual lesson - a
 * lesson without a group - was ignored even when it was the most recent lesson of the student. The
 * badge is now derived from the last lesson of any kind, and when several lessons share the last
 * day the one created last counts.
 */
class StudentStatusServiceGetStudentStatusesTest {

  private static final OffsetDateTime CREATED_AT =
      OffsetDateTime.of(2026, 10, 8, 12, 0, 0, 0, ZoneOffset.UTC);

  private static final UUID STUDENT_ID = UUID.randomUUID();
  private static final UUID GROUP_ID = UUID.randomUUID();
  private static final UUID GROUP_LESSON_ID = UUID.randomUUID();
  private static final UUID INDIVIDUAL_LESSON_ID = UUID.randomUUID();

  private final StudentStatusService service = new StudentStatusService();

  @Test
  void marksPresentFromTheIndividualLessonWhenItIsTheLastOne() {
    List<VisitResponse> visits =
        List.of(
            visit(GROUP_LESSON_ID, VisitStatus.ABSENT, VisitType.REGULAR),
            visit(INDIVIDUAL_LESSON_ID, VisitStatus.PRESENT, VisitType.REGULAR));
    List<LessonResponse> lessons =
        List.of(
            lesson(GROUP_LESSON_ID, GROUP_ID, LocalDate.of(2026, 9, 1), CREATED_AT),
            lesson(INDIVIDUAL_LESSON_ID, null, LocalDate.of(2026, 10, 8), CREATED_AT));

    Set<StudentStatus> statuses = service.getStudentStatuses(visits, List.of(), lessons, false);

    assertThat(statuses).contains(StudentStatus.PRESENT).doesNotContain(StudentStatus.MISSING);
  }

  @Test
  void marksMissingFromTheGroupLessonWhenItIsTheLastOne() {
    List<VisitResponse> visits =
        List.of(
            visit(INDIVIDUAL_LESSON_ID, VisitStatus.PRESENT, VisitType.REGULAR),
            visit(GROUP_LESSON_ID, VisitStatus.ABSENT, VisitType.REGULAR));
    List<LessonResponse> lessons =
        List.of(
            lesson(INDIVIDUAL_LESSON_ID, null, LocalDate.of(2026, 9, 1), CREATED_AT),
            lesson(GROUP_LESSON_ID, GROUP_ID, LocalDate.of(2026, 10, 8), CREATED_AT));

    Set<StudentStatus> statuses = service.getStudentStatuses(visits, List.of(), lessons, false);

    assertThat(statuses).contains(StudentStatus.MISSING).doesNotContain(StudentStatus.PRESENT);
  }

  @Test
  void prefersTheLessonCreatedLastWhenSeveralLessonsShareTheLastDay() {
    LocalDate day = LocalDate.of(2026, 10, 8);
    List<VisitResponse> visits =
        List.of(
            visit(GROUP_LESSON_ID, VisitStatus.ABSENT, VisitType.REGULAR),
            visit(INDIVIDUAL_LESSON_ID, VisitStatus.PRESENT, VisitType.REGULAR));
    List<LessonResponse> lessons =
        List.of(
            lesson(GROUP_LESSON_ID, GROUP_ID, day, CREATED_AT),
            lesson(INDIVIDUAL_LESSON_ID, null, day, CREATED_AT.plusHours(2)));

    Set<StudentStatus> statuses = service.getStudentStatuses(visits, List.of(), lessons, false);

    assertThat(statuses).contains(StudentStatus.PRESENT).doesNotContain(StudentStatus.MISSING);
  }

  @Test
  void marksPresentForAStudentWithoutAGroup() {
    List<VisitResponse> visits =
        List.of(visit(INDIVIDUAL_LESSON_ID, VisitStatus.PRESENT, VisitType.REGULAR));
    List<LessonResponse> lessons =
        List.of(lesson(INDIVIDUAL_LESSON_ID, null, LocalDate.of(2026, 10, 8), CREATED_AT));

    Set<StudentStatus> statuses = service.getStudentStatuses(visits, List.of(), lessons, false);

    assertThat(statuses).contains(StudentStatus.PRESENT);
  }

  @Test
  void marksInactiveWhenThereAreNoMarkedVisitsAndNoPayments() {
    Set<StudentStatus> statuses =
        service.getStudentStatuses(List.of(), List.of(), List.of(), false);

    assertThat(statuses).containsExactly(StudentStatus.INACTIVE);
  }

  @Test
  void marksPaidWhenTheSubscriptionCoversTheLastLessonDay() {
    LocalDate lastLessonDay = LocalDate.of(2026, 10, 8);
    List<VisitResponse> visits =
        List.of(visit(INDIVIDUAL_LESSON_ID, VisitStatus.PRESENT, VisitType.REGULAR));
    List<LessonResponse> lessons =
        List.of(lesson(INDIVIDUAL_LESSON_ID, null, lastLessonDay, CREATED_AT));

    Set<StudentStatus> statuses =
        service.getStudentStatuses(visits, List.of(payment(lastLessonDay)), lessons, false);

    assertThat(statuses).contains(StudentStatus.PAID).doesNotContain(StudentStatus.UNPAID);
  }

  @Test
  void marksUnpaidWhenTheSubscriptionEndsBeforeTheLastLessonDay() {
    LocalDate lastLessonDay = LocalDate.of(2026, 10, 8);
    List<VisitResponse> visits =
        List.of(visit(INDIVIDUAL_LESSON_ID, VisitStatus.PRESENT, VisitType.REGULAR));
    List<LessonResponse> lessons =
        List.of(lesson(INDIVIDUAL_LESSON_ID, null, lastLessonDay, CREATED_AT));

    Set<StudentStatus> statuses =
        service.getStudentStatuses(
            visits, List.of(payment(lastLessonDay.minusDays(1))), lessons, false);

    assertThat(statuses).contains(StudentStatus.UNPAID).doesNotContain(StudentStatus.PAID);
  }

  @Test
  void marksFreeInsteadOfPaidForAStudentWhoStudiesForFree() {
    LocalDate lastLessonDay = LocalDate.of(2026, 10, 8);
    List<VisitResponse> visits =
        List.of(visit(INDIVIDUAL_LESSON_ID, VisitStatus.PRESENT, VisitType.REGULAR));
    List<LessonResponse> lessons =
        List.of(lesson(INDIVIDUAL_LESSON_ID, null, lastLessonDay, CREATED_AT));

    Set<StudentStatus> statuses =
        service.getStudentStatuses(visits, List.of(payment(lastLessonDay)), lessons, true);

    assertThat(statuses)
        .contains(StudentStatus.FREE)
        .doesNotContain(StudentStatus.PAID, StudentStatus.UNPAID);
  }

  @Test
  void marksFreeInsteadOfUnpaidForAStudentWhoStudiesForFree() {
    List<VisitResponse> visits =
        List.of(visit(INDIVIDUAL_LESSON_ID, VisitStatus.PRESENT, VisitType.REGULAR));
    List<LessonResponse> lessons =
        List.of(lesson(INDIVIDUAL_LESSON_ID, null, LocalDate.of(2026, 10, 8), CREATED_AT));

    Set<StudentStatus> statuses = service.getStudentStatuses(visits, List.of(), lessons, true);

    assertThat(statuses)
        .contains(StudentStatus.FREE)
        .doesNotContain(StudentStatus.PAID, StudentStatus.UNPAID);
  }

  @Test
  void marksFreeInsteadOfInactiveForAStudentWhoStudiesForFreeAndHasNoActivity() {
    Set<StudentStatus> statuses = service.getStudentStatuses(List.of(), List.of(), List.of(), true);

    assertThat(statuses).containsExactly(StudentStatus.FREE);
  }

  private static VisitResponse visit(UUID lessonId, VisitStatus status, VisitType type) {
    return new VisitResponse(UUID.randomUUID(), status, type, lessonId, STUDENT_ID, CREATED_AT);
  }

  private static LessonResponse lesson(
      UUID lessonId, UUID groupId, LocalDate date, OffsetDateTime createdAt) {
    return new LessonResponse(lessonId, date, createdAt, groupId);
  }

  private static TransactionResponse payment(LocalDate paidUntil) {
    return new TransactionResponse(
        UUID.randomUUID(),
        BigDecimal.TEN,
        paidUntil,
        TransactionType.INCOME,
        CREATED_AT,
        new StudentPaymentDetailsResponse(STUDENT_ID, paidUntil, null));
  }
}
