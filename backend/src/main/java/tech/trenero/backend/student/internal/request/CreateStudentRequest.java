package tech.trenero.backend.student.internal.request;

import java.time.LocalDate;
import java.util.UUID;

public record CreateStudentRequest(
    String fullName, LocalDate birthdate, String phone, String note, UUID groupId) {}
