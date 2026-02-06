package org.trenero.backend.lesson.internal.request;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import org.trenero.backend.common.domain.StudentVisit;

public record CreateLessonRequest(
    @NotNull UUID groupId, @NotNull LocalDate date, List<StudentVisit> students) {
  public CreateLessonRequest {
    students = students == null ? List.of() : students;
  }
}
