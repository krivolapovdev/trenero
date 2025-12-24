package tech.trenero.backend.attendance.internal.input;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record CreateAttendanceInput(
    @NotNull UUID lessonId, @NotNull UUID studentId, boolean present) {}
