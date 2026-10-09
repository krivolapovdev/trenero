package org.trenero.backend.student.internal.request;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;

public record CreateStudentRequest(
    @NotNull String fullName, LocalDate birthdate, String phone, String note) {}
