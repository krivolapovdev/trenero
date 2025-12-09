package tech.trenero.backend.common.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.time.LocalDate;
import java.util.UUID;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record StudentResponse(
    UUID id, String fullName, String phone, LocalDate birthDate, String note) {}
