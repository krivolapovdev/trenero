package tech.trenero.backend.common.response;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record UserResponse(@NotNull UUID id, @NotNull @NotBlank String email) {}
