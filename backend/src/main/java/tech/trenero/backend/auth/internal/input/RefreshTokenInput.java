package tech.trenero.backend.auth.internal.input;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record RefreshTokenInput(@NotNull @NotBlank String refreshToken) {}
