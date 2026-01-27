package tech.trenero.backend.auth.internal.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record OAuth2LoginRequest(@NotNull @NotBlank String token) {}
