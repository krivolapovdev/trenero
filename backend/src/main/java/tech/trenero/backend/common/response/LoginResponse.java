package tech.trenero.backend.common.response;

import jakarta.validation.constraints.NotNull;

public record LoginResponse(@NotNull UserResponse user, @NotNull JwtTokensResponse jwtTokens) {}
