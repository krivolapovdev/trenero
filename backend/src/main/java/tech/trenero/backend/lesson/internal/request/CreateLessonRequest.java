package tech.trenero.backend.lesson.internal.request;

import jakarta.validation.constraints.NotNull;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import tech.trenero.backend.common.domain.StudentVisit;

public record CreateLessonRequest(
    @NotNull UUID groupId, @NotNull OffsetDateTime startDateTime, List<StudentVisit> students) {
  public CreateLessonRequest {
    students = students == null ? List.of() : students;
  }
}
