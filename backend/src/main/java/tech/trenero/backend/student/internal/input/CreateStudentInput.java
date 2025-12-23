package tech.trenero.backend.student.internal.input;

import java.time.LocalDate;
import java.util.UUID;

public record CreateStudentInput(
    String fullName, LocalDate birthDate, String phone, String note, UUID groupId) {}
