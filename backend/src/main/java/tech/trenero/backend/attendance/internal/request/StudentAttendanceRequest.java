package tech.trenero.backend.attendance.internal.request;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record StudentAttendanceRequest(@NotNull UUID studentId, boolean present) {}
