package org.trenero.backend.auth.internal.request;

import jakarta.validation.constraints.NotBlank;

public record OAuth2LoginRequest(@NotBlank String token) {}
