package tech.trenero.backend.auth.internal.dto;

import tech.trenero.backend.common.dto.UserDto;

public record LoginPayload(UserDto user, JwtTokens jwtTokens) {}
