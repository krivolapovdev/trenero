package tech.trenero.backend.auth.internal.request;

import jakarta.validation.constraints.NotNull;

public record OAuth2IdTokenRequest(@NotNull String idToken) {}
