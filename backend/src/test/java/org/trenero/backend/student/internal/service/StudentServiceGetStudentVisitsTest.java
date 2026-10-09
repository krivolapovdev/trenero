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
import org.junit.jupiter.api.Test;
import org.trenero.backend.common.domain.VisitStatus;
import org.trenero.backend.common.domain.VisitType;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.lesson.external.response.LessonResponse;
import org.trenero.backend.lesson.external.spi.LessonSpi;
import org.trenero.backend.student.internal.response.VisitWithLessonResponse;
import org.trenero.backend.visit.external.response.VisitResponse;
import org.trenero.backend.visit.external.spi.VisitSpi;

/**
 * Regression tests for {@link StudentService#getStudentVisits}.
 *
 * <p>The visits of a student used to be mapped against the lessons of their group only, so an
 * individual lesson - a lesson without a group - was dropped from the response even though it was
 * stored and the student had a visit for it.
 */
class StudentServiceGetStudentVisitsTest {

  private static final OffsetDateTime CREATED_AT =
      OffsetDateTime.of(2026, 10, 8, 0, 0, 0, 0, ZoneOffset.UTC);
  private static final LocalDate DATE = LocalDate.of(2026, 10, 8);

  private static final UUID STUDENT_ID = UUID.randomUUID();
  private static final UUID GROUP_ID = UUID.randomUUID();
  private static final UUID GROUP_LESSON_ID = UUID.randomUUID();
  private static final UUID INDIVIDUAL_LESSON_ID = UUID.randomUUID();

  private final JwtUser jwtUser = new JwtUser(UUID.randomUUID(), "owner@example.com");
  private final VisitSpi visitSpi = mock(VisitSpi.class);
  private final LessonSpi lessonSpi = mock(LessonSpi.class);

  @Test
  void returnsTheIndividualLessonNextToTheGroupLesson() {
    when(visitSpi.getVisitsByStudentId(STUDENT_ID, jwtUser))
        .thenReturn(List.of(visit(GROUP_LESSON_ID), visit(INDIVIDUAL_LESSON_ID)));
    when(lessonSpi.getLessonsByIds(List.of(GROUP_LESSON_ID, INDIVIDUAL_LESSON_ID), jwtUser))
        .thenReturn(
            Map.of(
                GROUP_LESSON_ID, lesson(GROUP_LESSON_ID, GROUP_ID),
                INDIVIDUAL_LESSON_ID, lesson(INDIVIDUAL_LESSON_ID, null)));

    List<VisitWithLessonResponse> visits = studentService().getStudentVisits(STUDENT_ID, jwtUser);

    assertThat(visits).hasSize(2);
    assertThat(visits.stream().map(visit -> visit.getLesson().getId()).toList())
        .containsExactly(GROUP_LESSON_ID, INDIVIDUAL_LESSON_ID);
    assertThat(visits.stream().map(visit -> visit.getLesson().getGroupId()).toList())
        .containsExactly(GROUP_ID, null);
  }

  @Test
  void returnsAnIndividualLessonOfAStudentWithoutAGroup() {
    when(visitSpi.getVisitsByStudentId(STUDENT_ID, jwtUser))
        .thenReturn(List.of(visit(INDIVIDUAL_LESSON_ID)));
    when(lessonSpi.getLessonsByIds(List.of(INDIVIDUAL_LESSON_ID), jwtUser))
        .thenReturn(Map.of(INDIVIDUAL_LESSON_ID, lesson(INDIVIDUAL_LESSON_ID, null)));

    List<VisitWithLessonResponse> visits = studentService().getStudentVisits(STUDENT_ID, jwtUser);

    assertThat(visits).hasSize(1);
    assertThat(visits.getFirst().getLesson().getGroupId()).isNull();
  }

  @Test
  void dropsAVisitWhoseLessonIsGone() {
    when(visitSpi.getVisitsByStudentId(STUDENT_ID, jwtUser))
        .thenReturn(List.of(visit(GROUP_LESSON_ID)));
    when(lessonSpi.getLessonsByIds(List.of(GROUP_LESSON_ID), jwtUser)).thenReturn(Map.of());

    assertThat(studentService().getStudentVisits(STUDENT_ID, jwtUser)).isEmpty();
  }

  /** Only the visits and the lessons are used by {@link StudentService#getStudentVisits}. */
  private StudentService studentService() {
    return new StudentService(null, null, null, null, null, null, null, visitSpi, lessonSpi, null);
  }

  private static VisitResponse visit(UUID lessonId) {
    return new VisitResponse(
        UUID.randomUUID(),
        VisitStatus.PRESENT,
        VisitType.REGULAR,
        lessonId,
        STUDENT_ID,
        CREATED_AT);
  }

  private static LessonResponse lesson(UUID lessonId, UUID groupId) {
    return new LessonResponse(lessonId, DATE, CREATED_AT, groupId);
  }
}
