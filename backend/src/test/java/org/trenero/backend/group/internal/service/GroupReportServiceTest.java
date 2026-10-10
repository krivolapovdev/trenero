package org.trenero.backend.group.internal.service;

import static org.assertj.core.api.Assertions.assertThat;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.trenero.backend.common.domain.TransactionType;
import org.trenero.backend.common.domain.VisitStatus;
import org.trenero.backend.common.domain.VisitType;
import org.trenero.backend.group.external.response.GroupResponse;
import org.trenero.backend.group.internal.response.GroupReportResponse;
import org.trenero.backend.group.internal.response.GroupReportStudentResponse;
import org.trenero.backend.lesson.external.response.LessonResponse;
import org.trenero.backend.student.external.response.StudentResponse;
import org.trenero.backend.transaction.external.response.StudentPaymentDetailsResponse;
import org.trenero.backend.transaction.external.response.TransactionResponse;
import org.trenero.backend.visit.external.response.VisitResponse;

/**
 * Unit tests for the monthly group report: the per day attendance grid, the {@code present/lessons}
 * result of every student, the paid flag and the group totals.
 */
class GroupReportServiceTest {

  private static final OffsetDateTime CREATED_AT =
      OffsetDateTime.of(2026, 1, 1, 0, 0, 0, 0, ZoneOffset.UTC);
  private static final LocalDate TODAY = LocalDate.of(2026, 10, 8);

  private static final UUID GROUP_ID = UUID.randomUUID();
  private static final UUID ANNA_ID = UUID.randomUUID();
  private static final UUID IVAN_ID = UUID.randomUUID();
  private static final UUID EXPIRES_IN_DECEMBER_ID = UUID.randomUUID();
  private static final UUID WITHOUT_PAYMENTS_ID = UUID.randomUUID();
  private static final UUID EXPIRES_IN_OCTOBER_ID = UUID.randomUUID();
  private static final UUID PAID_THROUGH_OCTOBER_ID = UUID.randomUUID();

  private final GroupReportService groupReportService = new GroupReportService();

  @Test
  void buildsDayGridForEveryDayOfTheReportedMonth() {
    // February 2026 has 28 days.
    UUID firstLessonId = UUID.randomUUID();
    UUID secondLessonId = UUID.randomUUID();

    List<LessonResponse> lessons =
        List.of(
            lesson(UUID.randomUUID(), LocalDate.of(2026, 2, 3)),
            lesson(firstLessonId, LocalDate.of(2026, 2, 5)),
            lesson(secondLessonId, LocalDate.of(2026, 2, 10)),
            // A lesson of another month must not leak into the report.
            lesson(UUID.randomUUID(), LocalDate.of(2026, 3, 3)));

    Map<UUID, List<VisitResponse>> visits =
        Map.of(
            ANNA_ID,
            List.of(
                visit(firstLessonId, ANNA_ID, VisitStatus.PRESENT),
                visit(secondLessonId, ANNA_ID, VisitStatus.PRESENT)),
            IVAN_ID,
            List.of(
                visit(firstLessonId, IVAN_ID, VisitStatus.PRESENT),
                // An absent visit counts as an absence.
                visit(secondLessonId, IVAN_ID, VisitStatus.ABSENT)));

    GroupReportResponse report =
        groupReportService.buildReport(
            group(),
            2026,
            2,
            List.of(student(ANNA_ID, "Anna Smirnova"), student(IVAN_ID, "Ivan Petrov")),
            lessons,
            visits,
            Map.of(),
            TODAY);

    assertThat(report.getDayCount()).isEqualTo(28);
    assertThat(report.getLessonDays())
        .as("the lesson days are the columns that carry a mark")
        .containsExactly(3, 5, 10);
    assertThat(report.getStudents()).hasSize(2);

    GroupReportStudentResponse anna = report.getStudents().get(0);
    assertThat(anna.getFullName()).isEqualTo("Anna Smirnova");
    assertThat(anna.getPresentDays())
        .as("Anna has no visit for the lesson of February 3rd")
        .containsExactly(5, 10);
    assertThat(anna.getPresentCount()).isEqualTo(2);
    assertThat(anna.getLessonCount()).isEqualTo(3);

    GroupReportStudentResponse ivan = report.getStudents().get(1);
    assertThat(ivan.getPresentDays())
        .as("Ivan missed February 3rd and was not marked on February 10th")
        .containsExactly(5);
    assertThat(ivan.getPresentCount()).isEqualTo(1);
    assertThat(ivan.getLessonCount()).isEqualTo(3);

    // The last cell of the report ("450/540") is the sum of the per student results.
    assertThat(report.getTotalPresent()).isEqualTo(3);
    assertThat(report.getTotalLessons()).isEqualTo(6);
  }

  @Test
  void ordersStudentsByNameAndKeepsAnEmptyReportWhenTheGroupHasNoStudents() {
    GroupReportResponse report =
        groupReportService.buildReport(
            group(),
            2026,
            2,
            List.of(student(IVAN_ID, "ivan petrov"), student(ANNA_ID, "Anna Smirnova")),
            List.of(lesson(UUID.randomUUID(), LocalDate.of(2026, 2, 3))),
            Map.of(),
            Map.of(),
            TODAY);

    assertThat(report.getStudents())
        .extracting(GroupReportStudentResponse::getFullName)
        .containsExactly("Anna Smirnova", "ivan petrov");
    assertThat(report.getTotalPresent()).isZero();
    assertThat(report.getTotalLessons()).isEqualTo(2);

    GroupReportResponse emptyReport =
        groupReportService.buildReport(
            group(), 2026, 2, List.of(), List.of(), Map.of(), Map.of(), TODAY);

    assertThat(emptyReport.getStudents()).isEmpty();
    assertThat(emptyReport.getTotalPresent()).isZero();
    assertThat(emptyReport.getTotalLessons()).isZero();
    assertThat(emptyReport.getDayCount()).as("February 2026 has 28 days").isEqualTo(28);
  }

  @Test
  void marksPaidOnlyWhenTheSubscriptionCoversTheReportedMonth() {
    List<LessonResponse> lessons = List.of(lesson(UUID.randomUUID(), LocalDate.of(2026, 2, 3)));

    // Past month: the last day of the month is the reference date.
    assertThat(
            paidFlags(
                groupReportService.buildReport(
                    group(), 2026, 2, paymentStudents(), lessons, Map.of(), payments(), TODAY)))
        .containsExactly(true, false, true, true);

    // Current month: today is the reference date, so an October 1st subscription already expired.
    assertThat(
            paidFlags(
                groupReportService.buildReport(
                    group(), 2026, 10, paymentStudents(), lessons, Map.of(), payments(), TODAY)))
        .containsExactly(true, false, false, true);

    // Future month: December is only paid when the subscription reaches into December.
    assertThat(
            paidFlags(
                groupReportService.buildReport(
                    group(), 2026, 12, paymentStudents(), lessons, Map.of(), payments(), TODAY)))
        .containsExactly(true, false, false, false);
  }

  private static List<Boolean> paidFlags(GroupReportResponse report) {
    return report.getStudents().stream().map(GroupReportStudentResponse::getPaid).toList();
  }

  /** Students with a subscription ending in December, none, October 1st and October 31st. */
  private static List<StudentResponse> paymentStudents() {
    return List.of(
        student(EXPIRES_IN_DECEMBER_ID, "Anna ExpiresInDecember"),
        student(WITHOUT_PAYMENTS_ID, "Boris WithoutPayments"),
        student(EXPIRES_IN_OCTOBER_ID, "Cyril ExpiresInOctober"),
        student(PAID_THROUGH_OCTOBER_ID, "Daria PaidThroughOctober"));
  }

  private static Map<UUID, List<TransactionResponse>> payments() {
    return Map.of(
        EXPIRES_IN_DECEMBER_ID,
        List.of(payment(EXPIRES_IN_DECEMBER_ID, LocalDate.of(2026, 12, 31))),
        EXPIRES_IN_OCTOBER_ID,
        List.of(payment(EXPIRES_IN_OCTOBER_ID, LocalDate.of(2026, 10, 1))),
        PAID_THROUGH_OCTOBER_ID,
        List.of(payment(PAID_THROUGH_OCTOBER_ID, LocalDate.of(2026, 10, 31))));
  }

  private static GroupResponse group() {
    return new GroupResponse(GROUP_ID, "Beginners", null, null, CREATED_AT);
  }

  private static StudentResponse student(UUID studentId, String fullName) {
    return new StudentResponse(studentId, fullName, null, null, null, CREATED_AT, false);
  }

  private static LessonResponse lesson(UUID lessonId, LocalDate date) {
    return new LessonResponse(lessonId, date, CREATED_AT, GROUP_ID);
  }

  private static VisitResponse visit(UUID lessonId, UUID studentId, VisitStatus status) {
    return new VisitResponse(
        UUID.randomUUID(), status, VisitType.REGULAR, lessonId, studentId, CREATED_AT);
  }

  private static TransactionResponse payment(UUID studentId, LocalDate paidUntil) {
    return new TransactionResponse(
        UUID.randomUUID(),
        new BigDecimal("3000.00"),
        LocalDate.of(2026, 1, 1),
        TransactionType.INCOME,
        CREATED_AT,
        new StudentPaymentDetailsResponse(studentId, paidUntil, null));
  }
}
