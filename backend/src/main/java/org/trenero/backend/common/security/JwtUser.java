package org.trenero.backend.common.security;

import java.util.UUID;
import lombok.NonNull;

public record JwtUser(@NonNull UUID id, @NonNull String email) {}
