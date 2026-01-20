package tech.trenero.backend.common.response;

public record LoginResponse(UserResponse user, JwtTokensResponse jwtTokens) {}
