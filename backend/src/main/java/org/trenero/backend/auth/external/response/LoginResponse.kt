package org.trenero.backend.auth.external.response

import jakarta.validation.constraints.NotNull
import org.trenero.backend.user.external.response.UserResponse

data class LoginResponse(
  @get:NotNull val user: UserResponse,
  @get:NotNull val jwtTokens: JwtResponse,
)
