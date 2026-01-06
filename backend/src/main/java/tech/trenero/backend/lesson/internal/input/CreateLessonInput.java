package tech.trenero.backend.lesson.internal.input;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

public record CreateLessonInput(
    @NotNull UUID groupId,
    @NotNull @PastOrPresent OffsetDateTime startDateTime,
    @NotNull List<StudentStatus> students) {
  public record StudentStatus(@NotNull UUID studentId, @NotNull Boolean present) {}
}
