package tech.trenero.backend.group.internal.request;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record RemoveStudentRequest(@NotNull UUID studentId) {}
