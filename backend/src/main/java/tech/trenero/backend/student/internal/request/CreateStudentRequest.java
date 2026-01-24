package tech.trenero.backend.student.internal.request;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.util.UUID;

public record CreateStudentRequest(
    @NotNull String fullName, LocalDate birthdate, String phone, String note, UUID groupId) {}
