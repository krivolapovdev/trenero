package tech.trenero.backend.student.request;

import jakarta.validation.constraints.NotBlank;
import java.time.LocalDate;
import java.util.Set;
import java.util.UUID;

public record StudentRequest(
    @NotBlank String fullName,
    String phone,
    LocalDate birthDate,
    String note,
    Set<UUID> studentGroups) {}
