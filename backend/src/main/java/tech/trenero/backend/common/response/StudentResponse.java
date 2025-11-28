package tech.trenero.backend.common.response;

import java.time.LocalDate;
import java.util.UUID;

public record StudentResponse(
    UUID id, String fullName, String phone, LocalDate birthDate, String note) {}
