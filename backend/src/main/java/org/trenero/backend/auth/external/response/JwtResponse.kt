package org.trenero.backend.auth.external.response

import jakarta.validation.constraints.NotNull

data class JwtResponse(
  @get:NotNull val accessToken: String,
  @get:NotNull val refreshToken: String,
)
