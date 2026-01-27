package tech.trenero.backend.auth.internal.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record RefreshTokenRequest(@NotNull @NotBlank String refreshToken) {}
