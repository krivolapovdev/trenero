package tech.trenero.backend.auth.internal.request;

import jakarta.validation.constraints.NotNull;

public record RefreshTokenRequest(@NotNull String refreshToken) {}
