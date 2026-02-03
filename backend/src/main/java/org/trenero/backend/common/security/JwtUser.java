package org.trenero.backend.common.security;

import java.util.UUID;

public record JwtUser(UUID userId, String email) {}
