package org.trenero.backend.common.response;

import jakarta.validation.constraints.NotNull;

public record JwtResponse(@NotNull String accessToken, @NotNull String refreshToken) {}
