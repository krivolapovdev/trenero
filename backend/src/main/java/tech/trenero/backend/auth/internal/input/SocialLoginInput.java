package tech.trenero.backend.auth.internal.input;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record SocialLoginInput(@NotNull @NotBlank String idToken) {}
