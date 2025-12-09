package tech.trenero.backend.attendance.internal.request;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public record LessonRequest(
    @NotNull UUID groupId,
    @NotNull LocalDateTime startDateTime,
    @NotNull LocalDateTime endDateTime,
    List<StudentAttendanceRequest> attendance) {
  public LessonRequest {
    attendance = attendance == null ? List.of() : attendance;
  }
}
