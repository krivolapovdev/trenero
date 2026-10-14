package org.trenero.backend.lesson.internal.service;

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
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.trenero.backend.TestDays;
import org.trenero.backend.common.domain.VisitStatus;
import org.trenero.backend.common.domain.VisitType;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.lesson.external.response.LessonResponse;
import org.trenero.backend.lesson.internal.response.LessonDetailsResponse;
import org.trenero.backend.student.external.response.StudentResponse;
import org.trenero.backend.student.external.spi.StudentSpi;
import org.trenero.backend.visit.external.response.VisitResponse;
import org.trenero.backend.visit.external.spi.VisitSpi;

/**
 * Regression tests for {@link LessonService#getLessonDetailsById}, which feeds the lesson page.
 *
 * <p>The details used to carry the visits alone, so the page had no name for a student that left
 * the group: the rows of the page are drawn from the students of the group, which no longer holds
 * them, and their visit was dropped as soon as the lesson was saved. The students the visits belong
 * to are now returned next to the visits.
 */
class LessonServiceGetLessonDetailsTest {

  private static final OffsetDateTime CREATED_AT =
      OffsetDateTime.of(2026, 10, 8, 0, 0, 0, 0, ZoneOffset.UTC);
  private static final OffsetDateTime DATE = TestDays.day(2026, 10, 8);

  private static final UUID LESSON_ID = UUID.randomUUID();
  private static final UUID GROUP_ID = UUID.randomUUID();
  private static final UUID CURRENT_STUDENT_ID = UUID.randomUUID();
  private static final UUID LEFT_STUDENT_ID = UUID.randomUUID();

  private final JwtUser jwtUser = new JwtUser(UUID.randomUUID(), "owner@example.com");
  private final LessonService self = mock(LessonService.class);
  private final VisitSpi visitSpi = mock(VisitSpi.class);
  private final StudentSpi studentSpi = mock(StudentSpi.class);

  @Test
  void returnsTheStudentsOfTheVisitsEvenAfterTheyLeftTheGroup() {
    when(self.getLessonById(LESSON_ID, jwtUser)).thenReturn(lesson());
    when(visitSpi.getVisitsByLessonId(LESSON_ID, jwtUser))
        .thenReturn(List.of(visit(CURRENT_STUDENT_ID), visit(LEFT_STUDENT_ID)));
    when(studentSpi.getStudentsByIds(List.of(CURRENT_STUDENT_ID, LEFT_STUDENT_ID), jwtUser))
        .thenReturn(
            Map.of(
                CURRENT_STUDENT_ID, student(CURRENT_STUDENT_ID, "Zoe Current"),
                LEFT_STUDENT_ID, student(LEFT_STUDENT_ID, "Anna Left")));

    LessonDetailsResponse details = lessonService().getLessonDetailsById(LESSON_ID, jwtUser);

    assertThat(details.studentVisits()).hasSize(2);
    assertThat(details.students())
        .as("the students are named next to their visit, so a left student keeps their row")
        .extracting(StudentResponse::getFullName)
        .containsExactly("Zoe Current", "Anna Left");
  }

  @Test
  void dropsAStudentOfAVisitThatIsGone() {
    when(self.getLessonById(LESSON_ID, jwtUser)).thenReturn(lesson());
    when(visitSpi.getVisitsByLessonId(LESSON_ID, jwtUser))
        .thenReturn(List.of(visit(CURRENT_STUDENT_ID), visit(LEFT_STUDENT_ID)));
    when(studentSpi.getStudentsByIds(List.of(CURRENT_STUDENT_ID, LEFT_STUDENT_ID), jwtUser))
        .thenReturn(Map.of(CURRENT_STUDENT_ID, student(CURRENT_STUDENT_ID, "Zoe Current")));

    LessonDetailsResponse details = lessonService().getLessonDetailsById(LESSON_ID, jwtUser);

    assertThat(details.students()).hasSize(1);
    assertThat(details.students().getFirst().getId()).isEqualTo(CURRENT_STUDENT_ID);
  }

  @Test
  void doesNotAskForTheStudentsOfALessonWithoutVisits() {
    when(self.getLessonById(LESSON_ID, jwtUser)).thenReturn(lesson());
    when(visitSpi.getVisitsByLessonId(LESSON_ID, jwtUser)).thenReturn(List.of());

    LessonDetailsResponse details = lessonService().getLessonDetailsById(LESSON_ID, jwtUser);

    assertThat(details.studentVisits()).isEmpty();
    assertThat(details.students()).isEmpty();
    verify(studentSpi, never()).getStudentsByIds(any(), any());
  }

  /** Only the visits and the students are used by {@link LessonService#getLessonDetailsById}. */
  private LessonService lessonService() {
    return new LessonService(null, null, self, visitSpi, studentSpi);
  }

  private static LessonResponse lesson() {
    return new LessonResponse(LESSON_ID, DATE, CREATED_AT, GROUP_ID);
  }

  private static StudentResponse student(UUID studentId, String fullName) {
    return new StudentResponse(studentId, fullName, null, null, null, CREATED_AT, false);
  }

  private static VisitResponse visit(UUID studentId) {
    return new VisitResponse(
        UUID.randomUUID(),
        VisitStatus.PRESENT,
        VisitType.REGULAR,
        LESSON_ID,
        studentId,
        CREATED_AT);
  }
}
