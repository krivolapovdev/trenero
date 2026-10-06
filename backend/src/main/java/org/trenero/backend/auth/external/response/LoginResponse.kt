package org.trenero.backend.auth.external.response

import io.swagger.v3.oas.annotations.media.Schema
import org.trenero.backend.user.external.response.UserResponse

data class LoginResponse(
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val user: UserResponse,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val jwtTokens: JwtResponse,
)
