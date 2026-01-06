package tech.trenero.backend.common.input;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record CreateAttendanceInput(
    @NotNull UUID lessonId, @NotNull UUID studentId, @NotNull Boolean present) {}
