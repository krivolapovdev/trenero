package org.trenero.backend.common.response;

import jakarta.validation.constraints.NotNull;

public record JwtTokensResponse(@NotNull String accessToken, @NotNull String refreshToken) {}
