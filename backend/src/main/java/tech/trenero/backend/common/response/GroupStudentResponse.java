package tech.trenero.backend.common.response;

import jakarta.validation.constraints.NotNull;
import java.time.OffsetDateTime;
import java.util.UUID;

public record GroupStudentResponse(
    @NotNull UUID id, @NotNull UUID groupId, @NotNull UUID studentId, OffsetDateTime leftAt) {}
