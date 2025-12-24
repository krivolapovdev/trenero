package tech.trenero.backend.attendance.internal.input;

import java.util.UUID;

public record CreateAttendanceInput(UUID lessonId, UUID studentId, boolean present) {}
