package tech.trenero.backend.auth.internal.response;

import com.fasterxml.jackson.annotation.JsonUnwrapped;
import tech.trenero.backend.common.response.UserResponse;

public record AuthResponse(
    @JsonUnwrapped UserResponse user, @JsonUnwrapped JwtTokenResponse jwtToken) {}
