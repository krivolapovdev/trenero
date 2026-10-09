package org.trenero.backend.lesson.internal.request;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import org.trenero.backend.common.domain.StudentVisit;

/**
 * Request to create a lesson.
 *
 * <p>A {@code groupId} creates a lesson for the whole group: every student of the group is stored
 * as a visit, the ones sent in {@code students} with their status and the rest as unmarked. A
 * {@code null} groupId creates an individual lesson: only the {@code students} that are sent are
 * stored as visits, which is how a lesson is recorded for a single student.
 */
public record CreateLessonRequest(
    UUID groupId, @NotNull LocalDate date, List<StudentVisit> students) {

  public CreateLessonRequest {
    students = students == null ? List.of() : students;
  }
}
