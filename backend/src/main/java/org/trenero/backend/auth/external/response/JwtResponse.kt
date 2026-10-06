package org.trenero.backend.auth.external.response

import io.swagger.v3.oas.annotations.media.Schema

data class JwtResponse(
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val accessToken: String,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val refreshToken: String,
)
