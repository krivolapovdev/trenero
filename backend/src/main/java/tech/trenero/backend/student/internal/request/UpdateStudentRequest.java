package tech.trenero.backend.student.internal.request;

import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

public record UpdateStudentRequest(
    Optional<String> fullName,
    Optional<LocalDate> birthdate,
    Optional<String> phone,
    Optional<String> note,
    Optional<UUID> groupId) {}
