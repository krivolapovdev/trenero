package tech.trenero.backend.auth.internal.response;

import tech.trenero.backend.common.response.JwtTokenResponse;
import tech.trenero.backend.common.response.UserResponse;

public record AuthResponse(UserResponse user, JwtTokenResponse jwtToken) {}
